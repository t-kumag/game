class Services::AtUserBankAccountsService
  def self.get_balance(user)
    Entities::AtUserBankAccount.find_by(at_user_id: user.id)
  end
end