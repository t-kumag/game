class ChangeColumnToAtUserBankAccounts20190626 < ActiveRecord::Migration[5.2]
  def up
    change_column :at_user_bank_accounts, :balance, :bigint, null: false, default: 0
    change_column :at_user_bank_accounts, :share,   false,   null: false, default: 0
  end

  def down
    change_column :at_user_bank_accounts, :balance
    change_column :at_user_bank_accounts, :share
  end
end