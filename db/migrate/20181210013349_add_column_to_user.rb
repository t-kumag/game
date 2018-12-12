class AddColumnToUser < ActiveRecord::Migration[5.2]
  def change

    # 追加
    add_column :users, :email, :string
    add_column :users, :token, :string
    add_column :users, :crypted_password, :string
    
  end
end

