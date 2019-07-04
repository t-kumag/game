class CreateAtSyncTransactionLatestDateLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :at_sync_transaction_latest_date_logs do |t|
      t.integer :at_user_bank_account_id
      t.integer :at_user_card_account_id
      t.integer :at_user_emoney_service_account_id
      t.datetime :latest_date, null: false
      t.timestamps
    end
  end
end
