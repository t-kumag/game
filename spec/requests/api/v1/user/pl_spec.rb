require 'rails_helper'

RSpec.describe 'pl_controller' do
  let(:user) { create(:user) }
  let(:headers) { { Authorization: 'Bearer ' + user.token} }
  let(:find_params) { {
    from: '2019-12-29',
    to: '2019-12-31',
    share: false
  } }
  let!(:at_grouped_category) { create(:at_grouped_category) }
  let!(:at_transaction_category) { create(:at_transaction_category) }
  # TODO 実際にレスポンスに値を入れる場合はtransaction系のデータ追加が必要

  describe '#summary' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/user/pl-summary", params: find_params, headers: headers
        expect(response.status).to eq 200
      end

      it 'body is not nil' do
        get "/api/v1/user/pl-summary", params: find_params, headers: headers

        response_json = JSON.parse(response.body)
        actual_app = response_json['app']
        expect(actual_app).not_to eq nil
      end
    end
  end

  describe '#categories' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/user/pl-categories", params: find_params, headers: headers
        expect(response.status).to eq 200
      end

      it 'body is not nil' do
        get "/api/v1/user/pl-categories", params: find_params, headers: headers

        response_json = JSON.parse(response.body)
        actual_app = response_json['app']
        expect(actual_app).not_to eq nil
      end
    end
  end

  describe '#grouped_categories' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/user/pl-grouped-categories", params: find_params, headers: headers
        expect(response.status).to eq 200
      end

      it 'body is not nil' do
        get "/api/v1/user/pl-grouped-categories", params: find_params, headers: headers

        response_json = JSON.parse(response.body)
        actual_app = response_json['app']
        expect(actual_app).not_to eq nil
      end
    end
  end
end
