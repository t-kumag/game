namespace :accumulation do

  desc "目標金額に応じて自動積立する"
  task move_money: :environment do

    goal_logs = []
    goals = []
    activities = []

    activities_goal_finished = Services::ActivityService.fetch_activities_goal_finished
    Entities::Goal.find_each do |g|
      Rails.logger.info("start accumulation ===============")
      begin
        old_goal_and_goal_logs = {}
        g.goal_settings.each do |gs|
          next unless has_bank_account?(g, gs)
          next unless check_goal_amount?(g, gs, activities_goal_finished)
          next unless check_balance?(g, gs)

          goal = Services::GoalService.get_goal(g, gs)
          goal_log =  Services::GoalLogService.get_goal_log(g, gs)

          unless old_goal_and_goal_logs.present?
            old_goal_and_goal_logs[:goal_logs] = goal_log
          else
            goal = Services::GoalService.update_goal_plus_current_amount(goal, gs, old_goal_and_goal_logs[:goal_logs])
            goal_log = Services::GoalLogService.update_goal_log(goal, gs, old_goal_and_goal_logs[:goal_logs])
          end
          goal_logs << goal_log
          goals << goal
          activities << Services::ActivityService.get_activity_data(gs.user_id, g.group_id, 'goal_add_money')
        end
      rescue ActiveRecord::RecordInvalid => db_err
        raise db_err
      rescue => exception
        #TODO: エラー処理については固定したフォーマットを考える
      end
    end
    Entities::Activity.import activities
    Entities::GoalLog.import goal_logs
    Entities::Goal.import goals, on_duplicate_key_update: [:current_amount]
    Rails.logger.info("end accumulation ===============")
  end

  private

  def check_balance?(goal, goal_setting)

    # 残高 = (銀行口座の残高 - 現在の積み立て済み金額 )
    balance_minus_goal = goal_setting.at_user_bank_account.balance - goal.current_amount

    # (残高) > 月額貯金額
    return true if balance_minus_goal > goal_setting.monthly_amount
    options = create_activity_options(goal)
    Services::ActivityService.create_activity(goal_setting.user_id, goal.group_id, Time.zone.now, :goal_fail_short_of_money, options)
    # ここはAPIエラーを投げる?
    false
  end

  def check_goal_amount?(goal, goal_setting, activities_goal_finished)

    return false if activities_goal_finished.include?(goal_setting.user_id)
    # 目標金額 > 現在の貯金額
    return true if goal.goal_amount > goal.current_amount


    # 目標達成メッセージの記入
    options = create_activity_options(goal)
    Services::ActivityService.create_activity(goal_setting.user_id, goal.group_id, Time.zone.now, :goal_finished, options)
    false
  end

  def has_bank_account?(goal, goal_setting)

    return true if goal_setting.at_user_bank_account.present?

    options = create_activity_options(goal)
    Services::ActivityService.create_activity(goal_setting.user_id, goal.group_id, Time.zone.now, :goal_fail_no_account, options)
    false
  end


  def create_activity_options(goal)
    options = {}
    options[:goal] = goal
    options[:transaction] = nil
    options
  end
end
