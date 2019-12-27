class ChangeColumnToUserManuallyCreatedTransaction < ActiveRecord::Migration[5.2]
  def change
    remove_reference :user_manually_created_transactions, :payment_method, foreign_key: true
  end
end
