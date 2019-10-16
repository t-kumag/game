class AddColumnToAtGroupedCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :at_grouped_categories, :category_type, :string
  end
end
