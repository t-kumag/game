namespace :accumulation do

  desc "目標金額に応じて自動積立する"
  task move_money: :environment do

    goal_logs = []
    goals = []

    Entities::User.find_each do |user|
      begin
        goal = Services::GoalService.new(user).get_goal_user(user.group_id)
        at_user_bank_account = Services::AtUserBankAccountsService.get_balance(user.at_user.id)

        at_user_bank_account.goal_settings.all.each do |goal_setting|
          if check_balance(at_user_bank_account, goal_setting, goal) && check_goal_amount(goal)
            goal_logs << Services::GoalService.new(user).get_goal_user_log_data(goal, goal_setting)
            goals << Services::GoalService.new(user).get_update_goal_data(goal, goal_setting)
          end
        end
      rescue ActiveRecord::RecordInvalid => db_err
        raise db_err
      rescue => exception
        #TODO: エラー処理については固定したフォーマットを考える
      end
    end
    Entities::GoalLog.import goal_logs, on_duplicate_key_update: [:goal_id, :at_user_bank_account_id, :before_current_amount, :after_current_amount]
    Entities::Goal.import goals, on_duplicate_key_update: [:id, :group_id, :user_id]
  end

  private
  def check_balance(at_user_bank_account, goal_setting, goal)

    balance_minus_goal = at_user_bank_account.balance - goal.current_amount

    # (銀行口座の残高 - 積み立て済み金額 ) > 月額貯金額
    if balance_minus_goal > goal_setting.monthly_amount
      return true
    end
    # ここはAPIエラーを投げる?
    return false
  end

  def check_goal_amount(goal)

    # 目標金額 > 現在の貯金額
    if goal.goal_amount > goal.current_amount
      return true
    end
    # ここはAPIエラーを投げる?
    return false
  end
end
