class AddDeletedAtColumnToParitipateGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :participate_groups, :deleted_at, :datetime
    add_index :participate_groups, :deleted_at
  end
end
