require 'rails_helper'

RSpec.describe 'categories_controller' do
  let(:user) { create(:user) }
  let(:headers) { { Authorization: 'Bearer ' + user.token} }

  describe '#index' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/categories", headers: headers
        expect(response.status).to eq 200
      end

      it 'body is not nil' do
        get "/api/v1/user/transactions", headers: headers

        response_json = JSON.parse(response.body)
        actual_app = response_json['app'];
        expect(actual_app).not_to eq nil
      end
    end
  end
end
