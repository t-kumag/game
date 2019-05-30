class ChangeUsedDateToUserDistributedTransactions < ActiveRecord::Migration[5.2]
  def up
    change_column :user_distributed_transactions, :used_date, :datetime
  end

  def down
    change_column :user_distributed_transactions, :used_date, :date
  end
end
