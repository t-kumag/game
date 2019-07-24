class CreateGoalSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :goal_settings do |t|
      t.references :goal, foreign_key: true
      t.references :at_user_bank_account, foreign_key: true
      t.integer :monthly_amount
      t.integer :first_amount
      t.timestamps
    end
  end
end
