class ChangeColumnToActivities20190626 < ActiveRecord::Migration[5.2]
  def up
    change_column :activities, :count, false, default: 0
  end

  def down
    change_column :activities, :count
  end
end

