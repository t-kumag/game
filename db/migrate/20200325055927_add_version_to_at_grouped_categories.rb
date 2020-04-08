class AddVersionToAtGroupedCategories < ActiveRecord::Migration[5.2]
  def change
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    add_column :at_grouped_categories, :version, :int, after: :updated_at
  end
end
