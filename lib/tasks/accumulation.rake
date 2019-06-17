namespace :accumulation do

  desc "目標金額に応じて自動積立する"
  task move_money: :environment do
    Entities::User.find_each do |user|

      begin
        goal = Services::GoalService.new(user).get_goal_user
        at_user_bank_account = Services::UserBankAccountsService.new.get_balance(user)

        at_user_bank_account.goal_settings.all.each do |goal_setting|
          if check_balance(at_user_bank_account, goal_setting, goal) && check_goal_amount(goal)
            Services::GoalService.new(user).update_current_amount(goal, goal_setting)
          end
        end
      rescue ActiveRecord::RecordInvalid => db_err
        raise db_err
      rescue => exception
        p exception
        #TODO: エラー処理については固定したフォーマットを考える
      end
    end
  end

  private
  def check_balance(at_user_bank_account, goal_setting, goal)

    balance_minus_purpose = at_user_bank_account.balance - goal.current_amount

    # (銀行口座の残高 - 積み立て済み金額 ) < 月額貯金額
    if balance_minus_purpose > goal_setting.monthly_amount
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
