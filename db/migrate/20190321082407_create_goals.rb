class CreateGoals < ActiveRecord::Migration[5.2]
  def change
    create_table :goals do |t|
      t.references :group, foreign_key: true
      t.references :user, foreign_key: true
      t.references :goal_type, foreign_key: true
      t.string :name
      t.string :img_url
      t.date :start_date
      t.date :end_date
      t.integer :goal_amount
      t.integer :current_amount

      t.timestamps
    end
  end
end
