class ChangeColumnToGoals20190626 < ActiveRecord::Migration[5.2]
  def up
    change_column :goals, :goal_amount,    :bigint, null: false, default: 0
    change_column :goals, :current_amount, :bigint, null: false, default: 0
  end

  def down
    change_column :goals, :goal_amount
    change_column :goals, :current_amount
  end
end
