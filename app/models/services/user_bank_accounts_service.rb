class Services::UserBankAccountsService
    #def initialize(user)
    #    @bank_accounts = user.at_user.at_user_bank_accounts
    #end

    #def user_bank_accounts
    #
    #end

    def get_balance(user)
      return Entities::AtUserBankAccount.find_by(at_user_id: user.id)
    end

    def minus_balance(at_user_bank_account, goal_setting)
      at_user_bank_account = Entities::AtUserBankAccount.find_by(at_user_id: at_user_bank_account.id)
      at_user_bank_account.balance = at_user_bank_account.balance - goal_setting.monthly_amount
      return at_user_bank_account.save
    end
end