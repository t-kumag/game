class AddMessageUrlToActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :url, :string, after: :activity_type
    add_column :activities, :message, :string, after: :url
    add_column :activities, :at_sync_transaction_latest_date, :datetime, after: :date
  end
end
