require 'rails_helper'

RSpec.describe Api::V2::Group::BankTransactionsController do
  let(:user) { create(:user, :with_at_user_bank_transactions, :with_partner_user) }
  let(:headers) { { 'Authorization': 'Bearer ' + user.token} }
  let(:params) { {
    from: '2018-12-31',
    to: '2019-01-01'
  } }
  let(:at_user_bank_account) { user.at_user.at_user_bank_accounts.first }
  let!(:at_grouped_category) { create(:at_grouped_category) }
  let!(:at_transaction_category) { create(:at_transaction_category) }

  describe '#index' do
    context 'success' do
      it 'response 200' do
        get "/api/v2/group/bank-accounts/#{at_user_bank_account.id}/transactions/", params: params, headers: headers
        expect(response.status).to eq 200
      end

      it 'body is not nil' do
        get "/api/v2/group/bank-accounts/#{at_user_bank_account.id}/transactions/", params: params, headers: headers

        response_json = JSON.parse(response.body)
        actual_transactions = response_json['transactions']
        expect(actual_transactions).not_to eq nil
      end
    end
  end
end
