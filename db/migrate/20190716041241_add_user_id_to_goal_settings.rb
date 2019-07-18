class AddUserIdToGoalSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :goal_settings, :user_id, :integer
  end
end