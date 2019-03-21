class CreateGoals < ActiveRecord::Migration[5.2]
  def change
    create_table :goals do |t|
      t.references :group, foreign_key: true
      t.references :user, foreign_key: true
      t.string :name
      t.string :imageUrl
      t.date :startDate
      t.date :endDate
      t.integer :goalAmount
      t.integer :currentAmount

      t.timestamps
    end
  end
end
