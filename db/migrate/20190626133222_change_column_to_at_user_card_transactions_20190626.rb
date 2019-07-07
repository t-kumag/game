class ChangeColumnToAtUserCardTransactions20190626 < ActiveRecord::Migration[5.2]
  def up
    change_column :at_user_card_transactions, :amount,         :bigint, null: false, default: 0
    change_column :at_user_card_transactions, :payment_amount, :bigint, null: false, default: 0
  end

  def down
    change_column :at_user_card_transactions, :amount
    change_column :at_user_card_transactions, :payment_amount
  end
end
