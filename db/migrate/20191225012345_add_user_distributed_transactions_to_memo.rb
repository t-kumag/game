class AddUserDistributedTransactionsToMemo < ActiveRecord::Migration[5.2]
  def change
    add_column :user_distributed_transactions, :memo, :text, default: nil, after: :used_location
  end
end
