namespace :accumulation do

  desc "目標金額に応じて自動積立する"
  task move_money: :environment do

    goal_logs = []
    goals = []
    activities = []

    Entities::Goal.find_each do |g|
      begin
        g.goal_settings.each do |gs|
          next unless gs.at_user_bank_account.present?
          next unless check_balance?(g, gs, gs.at_user_bank_account) || check_goal_amount?(g)
          if g.goal_settings.count >= 2
            g = Services::GoalService.monthly_amount(g, gs, gs.monthly_amount)
          else
            goal_logs << Services::GoalLogService.get_user_goal_log(g, gs)
            goals << Services::GoalService.get_update_goal_data(g, gs)
          end
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
