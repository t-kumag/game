class ChangeColumnToGoalLogs20190626 < ActiveRecord::Migration[5.2]
  def up
    change_column :goal_logs, :add_amount,     :bigint, null: false, default: 0
    change_column :goal_logs, :monthly_amount, :bigint, null: false, default: 0
    change_column :goal_logs, :first_amount,   :bigint, null: false, default: 0
    change_column :goal_logs, :before_current_amount, :bigint, null: false, default: 0
    change_column :goal_logs, :after_current_amount,  :bigint, null: false, default: 0
    change_column :goal_logs, :goal_amount,           :bigint, null: false, default: 0
  end

  def down
    change_column :goal_logs, :add_amount
    change_column :goal_logs, :monthly_amount
    change_column :goal_logs, :first_amount
    change_column :goal_logs, :before_current_amount
    change_column :goal_logs, :after_current_amount
    change_column :goal_logs, :goal_amount
  end
end



