FactoryBot.define do
  factory :at_user_asset_product, class: Entities::AtUserAssetProduct do
    at_user_stock_account_id           { nil }
    assets_product_type                { "BOV" }
    assets_product_profit_loss_amount  { 1_000 }
    assets_product_balance             { 10_000 }
  end
end
