class AddShareColumnsToUserManuallyCreatedTransactions < ActiveRecord::Migration[5.2]
  def change
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    add_reference :user_manually_created_transactions, :group, foreign_key: true, after: :user_id
    add_column :user_manually_created_transactions, :share, :boolean, after: :group_id
  end
end
