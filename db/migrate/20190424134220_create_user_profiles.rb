class CreateUserProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :user_profiles do |t|
      t.references :user, foreign_key: true
      t.date :birthday
      t.integer :gender
      t.integer :has_child
      t.timestamps
    end
  end
end
