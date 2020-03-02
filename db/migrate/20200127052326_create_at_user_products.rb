class CreateAtUserProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :at_user_products do |t|
      t.references :at_user_asset_product, foreign_key: true
      t.bigint :product_balance, default: 0
      t.bigint :product_bond_rate, default: 0
      t.string :product_name
      t.bigint :product_profit_loss_rate, default: 0
      t.bigint :product_profit_loss_amount, default: 0
      t.timestamps
    end
  end
end
