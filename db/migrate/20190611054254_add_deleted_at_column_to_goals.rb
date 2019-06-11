class AddDeletedAtColumnToGoals < ActiveRecord::Migration[5.2]
  def change
    add_column :goals, :deleted_at, :datetime
    add_index :goals, :deleted_at
  end
end
