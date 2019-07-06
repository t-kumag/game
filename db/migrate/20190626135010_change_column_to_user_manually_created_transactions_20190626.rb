class ChangeColumnToUserManuallyCreatedTransactions20190626 < ActiveRecord::Migration[5.2]
  def up
    change_column :user_manually_created_transactions, :amount, :bigint, null: false, default: 0
  end

  def down
    change_column :user_manually_created_transactions, :amount
  end
end
