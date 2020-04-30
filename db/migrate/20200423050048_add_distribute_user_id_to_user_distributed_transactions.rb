class AddDistributeUserIdToUserDistributedTransactions < ActiveRecord::Migration[5.2]
  def change
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    add_reference :user_distributed_transactions, :distribute_user, foreign_key: { to_table: :users }, after: :share
  end
end
