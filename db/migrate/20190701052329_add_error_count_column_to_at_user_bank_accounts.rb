class AddErrorCountColumnToAtUserBankAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :at_user_bank_accounts, :error_count, :tinyint
  end
end
