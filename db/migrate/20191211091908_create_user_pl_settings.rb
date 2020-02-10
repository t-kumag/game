class CreateUserPlSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :user_pl_settings do |t|
      t.references :user, foreign_key: true
      t.integer :pl_period_date , default: nil
      t.string :pl_type, default: nil
      t.integer :group_pl_period_date , default: nil
      t.string :group_pl_type, default: nil
      t.timestamps
    end
  end
end