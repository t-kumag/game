class AddOrderToAtGroupedCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :at_grouped_categories, :order_key, :integer
  end
end
