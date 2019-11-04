require 'rails_helper'

RSpec.describe 'bank_accounts_controller' do
  let(:user) { create(:user, :with_at_user) }
  let(:headers) { { Authorization: 'Bearer ' + user.token} }
  let(:params) { { share: false} }
  let(:at_user_bank_account) { create(:at_user_bank_account, at_user_id: user.at_user.id, share: true) }
  let(:at_user_bank_account_share_false) { create(:at_user_bank_account, at_user_id: user.at_user.id, share: false, fnc_id: 'test2') }

  describe '#index' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/user/bank-accounts", headers: headers
        expect(response.status).to eq 200
      end

      it 'response share is false only' do
        at_user_bank_account
        expect_bank_account = at_user_bank_account_share_false
        get "/api/v1/user/bank-accounts", headers: headers

        response_json = JSON.parse(response.body)
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
        get "/api/v1/user/bank-accounts"
        expect(response.status).to eq 401
      end
    end
  end

  describe '#summary' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/user/bank-accounts-summary", headers: headers
        expect(response.status).to eq 200
      end

      it 'response share is false only' do
        at_user_bank_account
        expect_amount = at_user_bank_account_share_false.balance
        get "/api/v1/user/bank-accounts-summary", headers: headers

        response_json = JSON.parse(response.body)
        expect(response_json['app']['amount']).to eq expect_amount
      end
    end
  end

  describe '#update' do
    let(:at_user_bank_account_after_update) { Entities::AtUserBankAccount.find(at_user_bank_account.id) }

    context 'success' do
      it 'response 200' do
        put "/api/v1/user/bank-accounts/#{at_user_bank_account.id}", params: params, headers: headers
        expect(response.status).to eq 200
      end

      it 'share is updated' do
        put "/api/v1/user/bank-accounts/#{at_user_bank_account.id}", params: params, headers: headers
        expect(at_user_bank_account_after_update.share).to eq params[:share]
      end
    end
  end

  describe '#destroy' do
    context 'success' do
      it 'response 200' do
        delete "/api/v1/user/bank-accounts/#{at_user_bank_account.id}", headers: headers
        expect(response.status).to eq 200
      end

      # 口座削除のテストは実行する場合、
      # osidori_api/app/models/services/at_user_service.rbの
      # def initialize の10行目と def delete_account の211～216行目をコメントアウト
      # it 'at_user_bank_account is nil' do
      #  delete "/api/v1/user/bank-accounts/#{at_user_bank_account.id}", headers: headers
      #  expect(Entities::AtUserBankAccount.find_by(id: at_user_bank_account.id)).to eq nil
      # end
    end
  end
end
