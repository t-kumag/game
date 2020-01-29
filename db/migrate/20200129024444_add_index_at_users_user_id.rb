class AddIndexAtUsersUserId < ActiveRecord::Migration[5.2]
  def change
    add_index :at_users, :user_id, unique:true, name: 'unique_index_at_users_on_user_id'
    remove_index :at_users, column: :user_id, name: 'index_at_users_on_user_id'
  end
end
