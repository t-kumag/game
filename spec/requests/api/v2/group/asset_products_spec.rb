require 'rails_helper'

RSpec.describe Api::V2::Group::AssetProductsController do
  let(:user) { create(:user, :with_at_user_asset_products, :with_partner_user) }
  let(:headers) { { 'Authorization': 'Bearer ' + user.token} }

  let(:at_user_stock_account) { user.at_user.at_user_stock_accounts.first }
  let(:at_user_asset_product) { at_user_stock_account.at_user_asset_products.first }
  
  describe '#index' do
    context 'success' do
      it 'response 200' do
        get "/api/v2/Group/stock-accounts/#{at_user_stock_account.id}/asset-products/", headers: headers
        expect(response.status).to eq 200
      end

      it 'response json' do
        expect_asset_product = at_user_asset_product

        get "/api/v2/Group/stock-accounts/#{at_user_stock_account.id}/asset-products/", headers: headers
        response_json = JSON.parse(response.body)

        asset_products = response_json['asset_products']
        expect(asset_products.length).to eq 1
        expect(asset_products[0]['at_user_asset_product_id']).to eq expect_asset_product.id
        expect(asset_products[0]['assets_product_type']).to eq Entities::AtUserAssetProduct::ASSETS_PRODUCT_NAME[expect_asset_product.assets_product_type]
        expect(asset_products[0]['assets_product_balance']).to eq expect_asset_product.assets_product_balance
        expect(asset_products[0]['assets_product_profit_loss_amount']).to eq expect_asset_product.assets_product_profit_loss_amount
      end
    end

    context 'error' do
      it 'response 401' do
        get "/api/v2/user/stock-accounts/#{at_user_stock_account.id}/asset-products/"
        expect(response.status).to eq 401
      end
    end
  end
end
