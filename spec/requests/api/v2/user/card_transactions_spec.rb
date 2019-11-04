require 'rails_helper'

RSpec.describe 'card_transactions_controller' do
  let(:user) { create(:user, :with_at_user_card_transactions) }
  let(:headers) { { 'Authorization': 'Bearer ' + user.token} }
  let(:find_params) { {
    from: '2018-12-31',
    to: '2019-01-01'
  } }
  let(:at_user_card_account) { user.at_user.at_user_card_accounts.first }
  let(:at_user_card_transaction) { at_user_card_account.at_user_card_transactions.first }
  let!(:at_grouped_category) { create(:at_grouped_category) }
  let!(:at_transaction_category) { create(:at_transaction_category) }

  describe '#index' do
    context 'success' do
      it 'response 200' do
        get "/api/v2/user/card-accounts/#{at_user_card_account.id}/transactions/", params: find_params, headers: headers
        expect(response.status).to eq 200
      end

      it 'body is not nil' do
        at_user_card_transaction
        get "/api/v2/user/card-accounts/#{at_user_card_account.id}/transactions/", params: find_params, headers: headers

        response_json = JSON.parse(response.body)
        actual_transactions = response_json['transactions'];
        expect(actual_transactions).not_to eq nil
      end
    end
  end
end
