namespace :accumulation do

  desc "目標金額に応じて自動積立する"
  task move_money: :environment do

    goal_logs = []
    goals = []
    activities = []

    Entities::Goal.find_each do |g|
      Rails.logger.info("start accumulation ===============")
      begin
        old_goal_and_goal_logs = {}
        g.goal_settings.each do |gs|
          next unless gs.at_user_bank_account.present?
          next unless check_balance?(g, gs, gs.at_user_bank_account)
          next unless check_goal_amount?(g)

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
          activities << Services::ActivityService.get_activity_data(g, gs, :goal_monthly_accumulation)
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
  def check_balance?(goal, goal_setting, at_user_bank_account)

    balance_minus_goal = at_user_bank_account.balance - goal.current_amount

    # (銀行口座の残高 - 積み立て済み金額 ) > 月額貯金額
    return true if balance_minus_goal > goal_setting.monthly_amount
    # ここはAPIエラーを投げる?
    false
  end

  def check_goal_amount?(goal)

    # 目標金額 > 現在の貯金額
    return true if goal.goal_amount > goal.current_amount
    # ここはAPIエラーを投げる?
    false
  end
end
