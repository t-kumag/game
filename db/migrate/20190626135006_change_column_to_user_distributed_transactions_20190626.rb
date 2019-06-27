class ChangeColumnToUserDistributedTransactions20190626 < ActiveRecord::Migration[5.2]
  def up
    change_column :user_distributed_transactions, :share,  false,   null: false, default: 0
    change_column :user_distributed_transactions, :amount, :bigint, null: false, default: 0
  end

  def down
    change_column :user_distributed_transactions, :share
    change_column :user_distributed_transactions, :amount
  end
end
