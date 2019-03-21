class AddColumnToGoalSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :goal_settings, :monthly_amount, :integer
    add_column :goal_settings, :bonus_amount, :integer
  end
end
