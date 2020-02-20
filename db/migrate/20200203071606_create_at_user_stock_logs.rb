class CreateAtUserStockLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :at_user_stock_logs do |t|
      t.references :at_user_stock_account, foreign_key: true
      t.bigint :balance, default: 0
      t.bigint :deposit_balance, default: 0
      t.string :profit_loss_amount, default: 0
      t.timestamps
    end
  end
end