class CreateAtUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :at_users do |t|
      t.references :user, foreign_key: true

      # t.string :at_user_id
      # t.string :at_user_password

      t.timestamps
    end
  end
end
