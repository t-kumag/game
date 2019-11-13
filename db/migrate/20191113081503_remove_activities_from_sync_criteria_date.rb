class RemoveActivitiesFromSyncCriteriaDate < ActiveRecord::Migration[5.2]
  def up
    remove_column :activities, :sync_criteria_date, :datetime
    remove_column :activities, :at_sync_transaction_latest_date, :datetime
  end

  def down
    add_column :activities, :sync_criteria_date, :datetime, after: :at_sync_transaction_latest_date
    add_column :activities, :at_sync_transaction_latest_date, :datetime, after: :at_sync_transaction_latest_date
  end
end
