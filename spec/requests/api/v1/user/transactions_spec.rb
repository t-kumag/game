require 'rails_helper'

RSpec.describe 'transactions_controller' do
  let(:user) { create(:user, :with_at_user_bank_transactions) }
  let(:headers) { { Authorization: 'Bearer ' + user.token} }
  let(:find_params) { {
    category_id: 1,
    share: 0,
    from: '2019-12-29',
    to: '2019-12-31',
  } }
  let!(:at_grouped_category) { create(:at_grouped_category) }
  let!(:at_transaction_category) { create(:at_transaction_category) }
  # TODO 実際にレスポンスに値を入れる場合はdistribution系のデータ追加が必要

  describe '#index' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/user/transactions", params: find_params, headers: headers
        expect(response.status).to eq 200
        p response.body
      end

      it 'response json' do
        get "/api/v1/user/transactions", params: find_params, headers: headers
        response_json = JSON.parse(response.body)
        actual_app = response_json['app'];

        expect(actual_app).not_to eq nil
      end
    end
  end

  describe '#grouped_transactions' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/user/grouped-transactions", params: find_params, headers: headers
        expect(response.status).to eq 200
        p response.body
      end

      it 'response json' do
        get "/api/v1/user/grouped-transactions", params: find_params, headers: headers
        response_json = JSON.parse(response.body)
        actual_app = response_json['app'];

        expect(actual_app).not_to eq nil
      end
    end
  end
end
