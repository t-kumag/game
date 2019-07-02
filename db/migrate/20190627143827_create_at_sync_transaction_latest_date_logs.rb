class CreateAtSyncTransactionLatestDateLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :at_sync_transaction_latest_date_logs do |t|
      t.integer :user_id , null:false
      t.string :rec_key, null:false
      t.datetime :latest_date, null: false
      t.timestamps
    end
  end
end
