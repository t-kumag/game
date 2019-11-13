class RemoveActivitiesFromSyncCriteriaDate < ActiveRecord::Migration[5.2]
  def up
    remove_column :activities, :sync_criteria_date, :datetime
  end

  def down
    add_column :activities, :sync_criteria_date, :datetime, after: :date
  end
end
