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

end