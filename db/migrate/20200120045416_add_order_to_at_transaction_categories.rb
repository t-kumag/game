class AddOrderToAtTransactionCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :at_transaction_categories, :order_key, :integer
  end
end
