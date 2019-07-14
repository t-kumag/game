class Services::AtUserBankAccountsService

    def self.get_balance(user)
      Entities::AtUserBankAccount.find_by(at_user_id: user.id)
    end

    def self.get_balance_summary(group_id)
      Entities::AtUserBankAccount.where(group_id: group_id, share: true)
    end

end