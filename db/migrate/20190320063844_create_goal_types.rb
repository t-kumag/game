class CreateGoalTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :goal_types do |t|
      t.string :img_url
      t.string :name
      t.timestamps
    end
  end
end
