class AddColumnToBalanceLogs < ActiveRecord::Migration[5.2]
  def change
    rename_column :balance_logs, :amount, :balance
    change_column :balance_logs, :balance, :bigint, null: false, default: 0
    add_reference :balance_logs, :wallet, foreign_key: true
    add_column :balance_logs, :base_balance, :bigint, null: false, default: 0
    add_index :balance_logs, [:wallet_id, :date], unique: true, name: :index_b_l_on_wallet_id_and_date
    add_index :balance_logs, [:at_user_bank_account_id, :date], unique: true, name: :index_b_l_on_at_user_bank_account_id_and_date
    add_index :balance_logs, [:at_user_emoney_service_account_id, :date], unique: true, name: :index_b_l_on_at_user_emoney_service_account_id_and_date
  end
end



