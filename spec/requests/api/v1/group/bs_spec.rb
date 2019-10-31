require 'rails_helper'

RSpec.describe Api::V1::Group::BsController do
  let(:user) { create(:user, :with_partner_user) }
  let(:headers) { { Authorization: 'Bearer ' + user.token} }
  # TODO 実際にレスポンスに値を入れる場合はtransaction系のデータ追加が必要

  describe '#summary' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/group/bs-summary", headers: headers
        expect(response.status).to eq 200
      end

      it 'response json' do
        get "/api/v1/group/bs-summary", headers: headers
        response_json = JSON.parse(response.body)
        actual_app = response_json['app']
        expect(actual_app).not_to eq nil
      end
    end
  end
end
