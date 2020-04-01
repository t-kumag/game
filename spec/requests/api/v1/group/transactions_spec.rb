require 'rails_helper'

RSpec.describe Api::V1::Group::TransactionsController do
  let(:user) { create(:user, :with_partner_user) }
  let(:headers) { { Authorization: 'Bearer ' + user.token} }
  let(:params) { {
    category_id: 1,
    share: 0,
    from: '2020-01-29',
    to: '202020-01-31',
  } }
  let!(:at_grouped_category) { create(:at_grouped_category) }
  let!(:at_transaction_category) { create(:at_transaction_category) }

  describe '#index' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/group/transactions", params: params, headers: headers
        expect(response.status).to eq 200
      end

      it 'body is not nil' do
        get "/api/v1/group/transactions", params: params, headers: headers

        response_json = JSON.parse(response.body)
        actual_app = response_json['app']
        expect(actual_app).not_to eq nil
      end
    end
  end

  describe '#grouped_transactions' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/group/grouped-transactions", params: params, headers: headers
        expect(response.status).to eq 200
      end

      it 'body is not nil' do
        get "/api/v1/group/grouped-transactions", params: params, headers: headers

        response_json = JSON.parse(response.body)
        actual_app = response_json['app']
        expect(actual_app).not_to eq nil
      end
    end
  end
end
