class ChangeColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :crypted_password
    add_column :users, :password_digest, :string
    add_column :users, :email_authenticated, :boolean, default: false
  end
end
