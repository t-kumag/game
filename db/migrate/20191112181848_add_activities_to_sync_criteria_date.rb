class AddActivitiesToSyncCriteriaDate < ActiveRecord::Migration[5.2]
  def up
    add_column :activities, :sync_criteria_date, :datetime, after: :at_sync_transaction_latest_date
  end

  def down
    remove_column :activities, :sync_criteria_date, :datetime
  end
end
