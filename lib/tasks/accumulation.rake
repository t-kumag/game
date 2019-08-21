namespace :accumulation do

  desc "目標金額に応じて自動積立する"
  task move_money: :environment do

    goal_logs = []
    goals = []
    activities = []

    Entities::User.find_each do |user|
      begin
        goal = Services::GoalService.new(user).get_goal_user(user.group_id)

        user.at_user.at_user_bank_accounts.each do |at_user_bank_account|
          binding.pry
          at_user_bank_account.goal_settings.each do |gs|
            next unless check_balance(at_user_bank_account, gs, goal) || check_goal_amount(goal)
            goal_logs << Services::GoalLogService.get_user_goal_log(goal, gs)
            goals << Services::GoalService.new(user).get_update_goal_data(goal, gs)
            activities << Services::ActivityService.get_activity_data(user, 'goal_add_money')
          end
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
  def check_balance(at_user_bank_account, goal_setting, goal)

    balance_minus_goal = at_user_bank_account.balance - goal.current_amount

    # (銀行口座の残高 - 積み立て済み金額 ) > 月額貯金額
    return true if balance_minus_goal > goal_setting.monthly_amount
    # ここはAPIエラーを投げる?
    false
  end

  def check_goal_amount(goal)

    # 目標金額 > 現在の貯金額
    return true if goal.goal_amount > goal.current_amount
    # ここはAPIエラーを投げる?
    false
  end
end
