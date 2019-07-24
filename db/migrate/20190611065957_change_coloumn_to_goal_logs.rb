class ChangeColoumnToGoalLogs < ActiveRecord::Migration[5.2]
  def change
    remove_column :goal_logs, :before_goal_amount
    remove_column :goal_logs, :after_goal_amount
    add_column :goal_logs, :goal_amount, :integer
    add_column :goal_logs, :add_date, :datetime
  end
end