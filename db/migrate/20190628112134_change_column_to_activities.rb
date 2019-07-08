class ChangeColumnToActivities < ActiveRecord::Migration[5.2]
  # 変更内容
  def up
    change_column :activities, :date, :datetime
  end

  def down
    change_column :activities, :date ,:date
  end

end
