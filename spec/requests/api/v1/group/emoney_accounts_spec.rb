require 'rails_helper'

RSpec.describe Api::V1::Group::EmoneyAccountsController do
  let(:user) { create(:user, :with_at_user, :with_partner_user) }
  let(:headers) { { Authorization: 'Bearer ' + user.token} }
  let(:at_user_emoney_service_account) { create(:at_user_emoney_service_account, at_user_id: user.at_user.id, share: true, group_id: user.group_id, balance: 1000) }

  describe '#index' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/group/emoney-accounts", headers: headers
        expect(response.status).to eq 200
      end

      it 'body is not nil' do
        at_user_emoney_service_account
        get "/api/v1/group/emoney-accounts", headers: headers

        response_json = JSON.parse(response.body)
        actual_app = response_json['app']
        expect(actual_app.class).not_to eq nil
      end
    end
  end

  describe '#summary' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/group/emoney-accounts-summary", headers: headers
        expect(response.status).to eq 200
      end

      it 'body is not nil' do
        get "/api/v1/group/emoney-accounts-summary", headers: headers

        response_json = JSON.parse(response.body)
        actual_app = response_json['app']
        expect(actual_app.class).not_to eq nil
      end
    end
  end
end
