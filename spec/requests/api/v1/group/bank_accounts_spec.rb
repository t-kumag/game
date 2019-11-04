require 'rails_helper'

RSpec.describe Api::V1::Group::BankAccountsController do
  let(:user) { create(:user, :with_at_user, :with_partner_user) }
  let(:headers) { { Authorization: 'Bearer ' + user.token} }
  let(:at_user_bank_account) { create(:at_user_bank_account, at_user_id: user.at_user.id, share: true, group_id: user.group_id) }
  let(:at_user_bank_account_share_false) { create(:at_user_bank_account, at_user_id: user.at_user.id, share: false, fnc_id: 'test2', group_id: user.group_id) }

  describe '#index' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/group/bank-accounts", headers: headers
        expect(response.status).to eq 200
      end

      it 'response share is true only' do
        expect_bank_account = at_user_bank_account
        at_user_bank_account_share_false
        get "/api/v1/group/bank-accounts", headers: headers

        response_json = JSON.parse(response.body)
        actual_app = response_json['app']
        expect(response_json['app'].length).to eq 1
        expect(response_json['app'][0]['account_id']).to eq expect_bank_account.id
        expect(response_json['app'][0]['name']).to eq expect_bank_account.fnc_nm
        expect(response_json['app'][0]['amount']).to eq expect_bank_account.balance
        expect(response_json['app'][0]['fnc_id']).to eq expect_bank_account.fnc_id
        expect(response_json['app'][0]['last_rslt_cd']).to eq expect_bank_account.last_rslt_cd
        expect(response_json['app'][0]['last_rslt_msg']).to eq expect_bank_account.last_rslt_msg
      end
    end

    context 'error' do
      it 'response 401' do
        get "/api/v1/group/bank-accounts"
        expect(response.status).to eq 401
      end
    end
  end

  describe '#summary' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/group/bank-accounts-summary", headers: headers
        expect(response.status).to eq 200
      end

      it 'response share is true only' do
        expect_amount = at_user_bank_account.balance
        at_user_bank_account_share_false
        get "/api/v1/group/bank-accounts-summary", headers: headers

        response_json = JSON.parse(response.body)
        expect(response_json['app']['amount']).to eq expect_amount
      end
    end
  end
end
