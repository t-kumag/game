require 'rails_helper'

RSpec.describe Api::V1::CategoriesController do
  let(:user) { create(:user) }
  let(:headers) { { Authorization: 'Bearer ' + user.token} }
  let!(:categories) { create(:at_grouped_category, :with_at_transaction_categories, :v2_at_grouped_category) }

  describe '#index' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/categories", headers: headers
        expect(response.status).to eq 200
      end

      it 'body is not nil version 1' do
        get "/api/v1/categories", headers: headers
        response_json = JSON.parse(response.body)

        actual_app = response_json['app']
        expect(actual_app).not_to eq nil
        expect(actual_app['at_grouped_categories'][0]['at_grouped_category_id']).to eq 1
      end

      it 'body is not nil version 2' do
        headers.store("CategoryVersion", "2")
        get "/api/v1/categories", headers: headers
        response_json = JSON.parse(response.body)

        actual_app = response_json['app']
        expect(actual_app).not_to eq nil
        expect(actual_app['at_grouped_categories'][0]['at_grouped_category_id']).to eq 2
      end
    end
  end
end
