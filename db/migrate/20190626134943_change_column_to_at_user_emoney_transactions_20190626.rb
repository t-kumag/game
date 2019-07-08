class ChangeColumnToAtUserEmoneyTransactions20190626 < ActiveRecord::Migration[5.2]
  def up
    change_column :at_user_emoney_transactions, :amount_receipt, :bigint, null: false, default: 0
    change_column :at_user_emoney_transactions, :amount_payment, :bigint, null: false, default: 0
    change_column :at_user_emoney_transactions, :balance,        :bigint, null: false, default: 0
  end

  def down
    change_column :at_user_emoney_transactions, :amount_receipt
    change_column :at_user_emoney_transactions, :amount_payment
    change_column :at_user_emoney_transactions, :balance
  end
end
