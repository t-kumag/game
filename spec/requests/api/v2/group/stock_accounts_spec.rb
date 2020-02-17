require 'rails_helper'

RSpec.describe Api::V2::Group::StockAccountsController do
  let(:user) { create(:user, :with_at_user, :with_partner_user) }
  let(:headers) { { Authorization: 'Bearer ' + user.token} }
  let(:at_user_stock_account) { create(:at_user_stock_account, at_user_id: user.at_user.id, share: true, group_id: user.group_id) }
  let(:at_user_stock_account_share_false) { create(:at_user_stock_account, at_user_id: user.at_user.id, share: false, fnc_id: 'test2', group_id: user.group_id) }

  describe '#index' do
    context 'success' do
      it 'response 200' do
        get "/api/v2/group/stock-accounts", headers: headers
        expect(response.status).to eq 200
      end

      it 'response share is false only' do
        expect_stock_account = at_user_stock_account
        get "/api/v2/group/stock-accounts", headers: headers

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
        get "/api/v2/group/stock-accounts"
        expect(response.status).to eq 401
      end
    end
  end
end
