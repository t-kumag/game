class AddDeletedAtToAtUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :at_users, :deleted_at, :datetime
    add_index :at_users, :deleted_at
  end
end
