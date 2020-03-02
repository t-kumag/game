class AddColumnToAtUserStockAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :at_user_stock_accounts, :name, :string
  end
end
