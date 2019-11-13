class RemoveAtSyncTransactionLatestDateLogFromUsers < ActiveRecord::Migration[5.2]
  def up
    remove_column :at_sync_transaction_latest_date_logs, :user_id
  end

  def down
    add_column :at_sync_transaction_latest_date_logs, :user_id, :integer, after: :at_user_emoney_service_account_id
  end
end
