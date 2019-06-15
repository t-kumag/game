namespace :accumulation do

  desc "目標金額に応じて自動積立する"
  task move_money: :environment do
    Entities::User.find_each do |user|

      begin
        goal = Services::GoalService.new(user).get_goal_user
        at_user_bank_account = Services::UserBankAccountsService.new.get_user_bank_balance(user)
        goal_setting = at_user_bank_account.goal_settings.last

        if check_balance(at_user_bank_account, goal_setting) && check_goal_ammount(goal)
          Services::GoalService.new(user).update_current_amount(goal, goal_setting)
        end
      rescue => exception
        #TODO: エラー処理については固定したフォーマットを考える
      end
    end
  end

  private
  def check_balance(at_user_bank_account, goal_setting)
    if at_user_bank_account.balance >= goal_setting.monthly_amount
      #もしOKだったらuser_accounts_serviceのbalanceをupdateをする
      return true
    end

    return false
  end

  def check_goal_ammount(goal)
    if goal.goal_amount >= goal.current_amount
      return true
    end

    return false
  end
end
