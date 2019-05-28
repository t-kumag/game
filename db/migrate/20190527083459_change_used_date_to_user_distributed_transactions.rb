class ChangeUsedDateToUserDistributedTransactions < ActiveRecord::Migration[5.2]
  def change
    change_column :user_distributed_transactions, :used_date, :datetime
  end
end
