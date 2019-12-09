namespace :accumulation do

  desc "目標金額に応じて自動積立する"
  task move_money: :environment do

    goal_logs = []
    goals = []
    activities = []
    goal_finishes = []

    Entities::Goal.find_each do |g|
      Rails.logger.info("start accumulation ===============")
      options = create_activity_options(g)
      begin
        old_goal_and_goal_logs = {}
        g.goal_settings.each do |gs|
          next unless has_bank_account?(g, gs)
          next unless check_goal_amount?(g)
          next unless check_balance?(g, gs)

          goal = Services::GoalService.get_goal(g, gs)
          goal_log =  Services::GoalLogService.get_goal_log(g, gs)

          unless old_goal_and_goal_logs.present?
            old_goal_and_goal_logs[:goal_logs] = goal_log
          else
            goal = Services::GoalService.update_goal_plus_current_amount(goal, gs, old_goal_and_goal_logs[:goal_logs])
            goal_log = Services::GoalLogService.update_goal_log(goal, gs, old_goal_and_goal_logs[:goal_logs])
          end
          # 「積立入金後の現在の貯金額」が「目標貯金総額」に到達したらtrueを返す
          goal_logs << goal_log
          goals << goal
          activities << Services::ActivityService.make_goal_activity(g, gs, :goal_monthly_accumulation)
          activities << Services::ActivityService.fetch_goal_finished(goal, options) if goal[:current_amount] >= goal[:goal_amount]
        end
      rescue ActiveRecord::RecordInvalid => db_err
        raise db_err
      rescue => exception
        #TODO: エラー処理については固定したフォーマットを考える
      end
    end
    activities.flatten!
    Entities::Activity.import activities
    Entities::GoalLog.import goal_logs
    Entities::Goal.import goals, on_duplicate_key_update: [:current_amount]
    Rails.logger.info("end accumulation ===============")
  end

  private

  def check_balance?(goal, goal_setting)

    # 残高 = (銀行口座の残高 - 現在の積み立て済み金額 )
    balance_minus_goal = goal_setting.at_user_bank_account.balance - goal.current_amount

    # 残高 >= 月額貯金額
    return true if balance_minus_goal >= goal_setting.monthly_amount

    options = create_activity_options(goal)
    Services::ActivityService.create_activity(goal_setting.user_id, goal.group_id, Time.zone.now, :goal_fail_short_of_money, options)
    # ここはAPIエラーを投げる?
    false
  end

  def check_goal_amount?(goal)
    # 現在の貯金額 >= 目標金額
    return true unless goal.current_amount >= goal.goal_amount
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
