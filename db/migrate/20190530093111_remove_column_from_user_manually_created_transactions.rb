class RemoveColumnFromUserManuallyCreatedTransactions < ActiveRecord::Migration[5.2]
  def change
    remove_column :user_manually_created_transactions, :group_id, :bigint
  end
end
