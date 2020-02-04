class ChangeIgnoreToUserDistributedTransactions < ActiveRecord::Migration[5.2]
  def change
    change_column :user_distributed_transactions, :ignore, :boolean, null: true
  end
end
