json.asset_products do
  json.array!(@asset_products) do |ap|
    json.at_user_asset_product_id ap.id
    json.assets_product_type Entities::AtUserAssetProduct::ASSETS_PRODUCT_NAME[ap.assets_product_type]
    json.assets_product_balance ap.assets_product_balance
    json.assets_product_profit_loss_amount ap.assets_product_profit_loss_amount
    json.at_user_products do
      json.array!(ap.at_user_products) do |product|
        json.at_user_product_id product.id
        json.product_balance product.product_balance
        json.product_bond_rate product.product_bond_rate
        json.product_name product.product_name
        json.product_profit_loss_amount product.product_profit_loss_amount
      end
    end
  end
end
