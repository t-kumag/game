class AddColumnToAtUser < ActiveRecord::Migration[5.2]
  def change
    add_column :at_users, :at_user_id, :string
  end
end
