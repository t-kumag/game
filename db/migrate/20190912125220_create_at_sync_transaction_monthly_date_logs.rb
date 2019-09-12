class CreateAtSyncTransactionMonthlyDateLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :at_sync_transaction_monthly_date_logs do |t|
      t.datetime :monthly_date, null: false
      t.references :at_user_bank_account, index: { name: 'index_a_s_t_l_on_at_user_bank_account_id' }, foreign_key: true
      t.references :at_user_card_account, index: { name: 'index_a_s_t_l_on_at_user_card_account_id' }, foreign_key: true
      t.references :at_user_emoney_service_account, index: { name: 'index_a_s_t_l_on_at_user_emoney_service_account_id' }, foreign_key: true
      t.timestamps
    end
  end
end
