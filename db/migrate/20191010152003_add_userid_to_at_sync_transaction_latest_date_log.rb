class AddUseridToAtSyncTransactionLatestDateLog < ActiveRecord::Migration[5.2]
  def change
    add_column :at_sync_transaction_latest_date_logs, :user_id, :integer, after: :at_user_emoney_service_account_id
  end
end
