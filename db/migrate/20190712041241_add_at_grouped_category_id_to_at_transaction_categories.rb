class AddAtGroupedCategoryIdToAtTransactionCategories < ActiveRecord::Migration[5.2]
  def change
    add_reference :at_transaction_categories, :at_grouped_categories
  end
end
