class CreateAtUserAssetProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :at_user_asset_products do |t|
      t.references :at_user_stock_account, foreign_key: true
      t.string :assets_product_type
      t.bigint :assets_product_profit_loss_amount, default: 0
      t.bigint :assets_product_balance, default: 0
      t.timestamps
    end
  end
end
