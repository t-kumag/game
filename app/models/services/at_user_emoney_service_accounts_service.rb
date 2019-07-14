class Services::AtUserEmoneyServiceAccountsService

    def self.get_balance_summary(group_id)
      Entities::AtUserEmoneyServiceAccount.where(group_id: group_id, share: true)
    end

end