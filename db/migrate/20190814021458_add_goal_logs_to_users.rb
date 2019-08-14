class AddGoalLogsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :goal_logs, :user_id, :integer
  end
end
