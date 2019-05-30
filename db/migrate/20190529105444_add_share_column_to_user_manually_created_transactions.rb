class AddShareColumnToUserManuallyCreatedTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :user_manually_created_transactions, :share, :boolean
  end
end
