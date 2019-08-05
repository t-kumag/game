class Services::AtUserBankAccountsService
  def self.get_balance(at_user_id)
    Entities::AtUserBankAccount.find_by(at_user_id: at_user_id)
  end
end