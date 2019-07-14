class Services::AtUserCardAccountsService

    def self.get_balance_summary(group_id)
      Entities::AtUserCardAccount.where(group_id: group_id, share: true)
    end

end