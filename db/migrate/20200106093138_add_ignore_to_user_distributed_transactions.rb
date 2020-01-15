class AddIgnoreToUserDistributedTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :user_distributed_transactions, :ignore, :boolean, default: false, null: false
  end
end
