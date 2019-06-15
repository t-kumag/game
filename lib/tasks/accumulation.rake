namespace :accumulation do

  desc "目標金額に応じて自動積立する"
  task move_money: :environment do
    Entities::User.find_each do |user|

      begin
        goal = Services::GoalService.new(user).get_goal_user
        at_user_bank_account = Services::UserBankAccountsService.new.get_balance(user)
        goal_setting = at_user_bank_account.goal_settings.last

        if check_balance(at_user_bank_account, goal_setting) && check_goal_amount(goal)
          Services::GoalService.new(user).update_current_amount(goal, goal_setting)
        end
      rescue ActiveRecord::RecordInvalid => db_err
        raise db_err
      rescue => exception
        #TODO: エラー処理については固定したフォーマットを考える
      end
    end
  end

  private
  def check_balance(at_user_bank_account, goal_setting)
    if at_user_bank_account.balance >= goal_setting.monthly_amount
      return Services::UserBankAccountsService.new.minus_balance(at_user_bank_account, goal_setting)
    end
    # ここはAPIエラーを投げる?
    return false
  end

  def check_goal_amount(goal)
    if goal.goal_amount >= goal.current_amount
      return true
    end
    # ここはAPIエラーを投げる?
    return false
  end
end
