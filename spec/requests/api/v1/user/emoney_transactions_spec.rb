require 'rails_helper'

RSpec.describe Api::V1::User::EmoneyTransactionsController do
  let(:user) { create(:user, :with_at_user_emoney_transactions) }
  let(:headers) { { 'Authorization': 'Bearer ' + user.token} }
  let(:params) { {
    at_transaction_category_id: 1,
    used_location: 'ミロク居酒屋 支払',
    share: false
  } }
  let(:at_user_emoney_service_account) { user.at_user.at_user_emoney_service_accounts.first }
  let(:at_user_emoney_transaction) { at_user_emoney_service_account.at_user_emoney_transactions.first }
  let(:user_distributed_transaction_after_update) {
    Entities::UserDistributedTransaction.find_by(at_user_emoney_transaction_id: at_user_emoney_transaction.id)
  }
  let!(:at_grouped_category) { create(:at_grouped_category) }
  let!(:at_transaction_category) { create(:at_transaction_category) }

  describe '#show' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/user/emoney-accounts/#{at_user_emoney_service_account.id}/transactions/#{at_user_emoney_transaction.id}", headers: headers
        expect(response.status).to eq 200
      end

      it 'body is not nil' do
        at_user_emoney_transaction
        get "/api/v1/user/emoney-accounts/#{at_user_emoney_service_account.id}/transactions/#{at_user_emoney_transaction.id}", headers: headers

        response_json = JSON.parse(response.body)
        actual_app = response_json['app']
        expect(actual_app).not_to eq nil
      end
    end
  end

  describe '#update' do
    context 'success' do
      it 'response 200' do
        put "/api/v1/user/emoney-accounts/#{at_user_emoney_service_account.id}/transactions/#{at_user_emoney_transaction.id}",
          params: params, headers: headers
        expect(response.status).to eq 200
      end

      it 'used_location is updated' do
        put "/api/v1/user/emoney-accounts/#{at_user_emoney_service_account.id}/transactions/#{at_user_emoney_transaction.id}",
          params: params, headers: headers
        expect(user_distributed_transaction_after_update.used_location).to eq params[:used_location]
      end
    end
  end
end
