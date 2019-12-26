class AddPaymentMethodIdToUserManuallyCreatedTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :user_manually_created_transactions, :payment_method_id, :integer, default: nil
  end
end
