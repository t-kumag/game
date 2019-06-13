class AddGroupIdColumnToAtUserBankAccounts < ActiveRecord::Migration[5.2]
  def change
    add_reference :at_user_bank_accounts, :group
  end
end
