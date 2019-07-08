class ChangeColumnToGoalSettings20190626 < ActiveRecord::Migration[5.2]
  def up
    change_column :goal_settings, :monthly_amount, :bigint, null: false, default: 0
    change_column :goal_settings, :first_amount,   :bigint, null: false, default: 0
  end

  def down
    change_column :goal_settings, :monthly_amount
    change_column :goal_settings, :first_amount
  end
end
