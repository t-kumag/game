require 'rails_helper'

RSpec.describe Api::V2::User::StockAccountsController do
  let(:user) { create(:user, :with_at_user) }
  let(:headers) { { Authorization: 'Bearer ' + user.token} }
  let(:params) { { stock_accounts: { share: false } } }
  let(:at_user_stock_account) { create(:at_user_stock_account, at_user_id: user.at_user.id, share: true) }
  let(:at_user_stock_account_share_false) { create(:at_user_stock_account, at_user_id: user.at_user.id, share: false, fnc_id: 'test2') }

  describe '#index' do
    context 'success' do
      it 'response 200' do
        get "/api/v2/user/stock-accounts", headers: headers
        expect(response.status).to eq 200
      end

      it 'response share is false only' do
        expect_stock_account = at_user_stock_account_share_false
        get "/api/v2/user/stock-accounts", headers: headers

        response_json = JSON.parse(response.body)
        expect(response_json['stock_accounts'].length).to eq 1
        expect(response_json['stock_accounts'][0]['account_id']).to eq expect_stock_account.id
        expect(response_json['stock_accounts'][0]['balance']).to eq expect_stock_account.balance
        expect(response_json['stock_accounts'][0]['name']).to eq expect_stock_account.fnc_nm
        expect(response_json['stock_accounts'][0]['fnc_id']).to eq expect_stock_account.fnc_id
        expect(response_json['stock_accounts'][0]['last_rslt_cd']).to eq expect_stock_account.last_rslt_cd
        expect(response_json['stock_accounts'][0]['last_rslt_msg']).to eq expect_stock_account.last_rslt_msg
      end
    end

    context 'error' do
      it 'response 401' do
        get "/api/v2/user/stock-accounts"
        expect(response.status).to eq 401
      end
    end
  end

  describe '#update' do
    let(:at_user_stock_account_after_update) { Entities::AtUserStockAccount.find(at_user_stock_account.id) }

    context 'success' do
      it 'response 204' do
        put "/api/v2/user/stock-accounts/#{at_user_stock_account.id}", params: params, headers: headers
        expect(response.status).to eq 204
      end

      it 'share is updated' do
        put "/api/v2/user/stock-accounts/#{at_user_stock_account.id}", params: params, headers: headers
        expect(at_user_stock_account_after_update.share).to eq params[:stock_accounts][:share]
      end
    end
  end

  describe '#destroy' do
    context 'success' do
      it 'response 204' do
        delete "/api/v2/user/stock-accounts/#{at_user_stock_account.id}", headers: headers
        expect(response.status).to eq 200
      end
    end
  end
end
