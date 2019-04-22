class ChangeDatatypeBalanceOfAtUserBankTransactions < ActiveRecord::Migration[5.2]
  def change
    change_column :at_user_bank_transactions, :balance, :string
  end
end
