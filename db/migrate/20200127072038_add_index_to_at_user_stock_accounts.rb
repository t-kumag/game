class AddIndexToAtUserStockAccounts < ActiveRecord::Migration[5.2]
  def change
    add_index :at_user_stock_accounts, [:at_user_id, :fnc_id], :unique => true, :name => 'at_user_stock_accounts_at_user_id_fnc_id'
  end
end
