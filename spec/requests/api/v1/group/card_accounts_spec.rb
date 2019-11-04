require 'rails_helper'

RSpec.describe Api::V1::Group::CardAccountsController do
  let(:user) { create(:user, :with_at_user, :with_partner_user) }
  let(:headers) { { Authorization: 'Bearer ' + user.token} }
  let(:at_user_card_account) { create(:at_user_card_account, at_user_id: user.at_user.id, share: true, group_id: user.group_id) }
  let(:at_user_card_account_share_false) { create(:at_user_card_account, at_user_id: user.at_user.id, share: false, fnc_id: 'test2', group_id: user.group_id) }

  describe '#index' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/group/card-accounts", headers: headers
        expect(response.status).to eq 200
      end

      it 'body is not nil' do
        expect_card_account = at_user_card_account
        at_user_card_account_share_false
        get "/api/v1/group/card-accounts", headers: headers

        response_json = JSON.parse(response.body)
        actual_app = response_json['app']
        expect(actual_app).not_to eq nil
      end
    end
  end

  describe '#summary' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/group/card-accounts-summary", headers: headers
        expect(response.status).to eq 200
      end

      it 'body is not nil' do
        get "/api/v1/group/card-accounts-summary", headers: headers

        response_json = JSON.parse(response.body)
        actual_app = response_json['app']
        expect(actual_app).not_to eq nil
      end
    end
  end
end
