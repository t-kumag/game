class CreateAtGroupedCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :at_grouped_categories do |t|
      t.timestamps

      t.string :category_name
    end
  end
end
