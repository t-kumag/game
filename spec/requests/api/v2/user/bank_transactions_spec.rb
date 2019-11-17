require 'rails_helper'

RSpec.describe 'bank_transactions_controller' do
  let(:user) { create(:user, :with_at_user_bank_transactions) }
  let(:headers) { { 'Authorization': 'Bearer ' + user.token} }
  let(:params) { {
    from: '2018-12-31',
    to: '2019-01-01'
  } }
  let(:at_user_bank_account) { user.at_user.at_user_bank_accounts.first }
  let(:at_user_bank_transaction) { at_user_bank_account.at_user_bank_transactions.first }
  let!(:at_grouped_category) { create(:at_grouped_category) }
  let!(:at_transaction_category) { create(:at_transaction_category) }

  describe '#index' do
    context 'success' do
      it 'response 200' do
        get "/api/v2/user/bank-accounts/#{at_user_bank_account.id}/transactions/", params: params, headers: headers
        expect(response.status).to eq 200
      end

      it 'response json' do
        expect_bank_transaction = at_user_bank_transaction
        expect_distributed_transaction = expect_bank_transaction.user_distributed_transaction

        get "/api/v2/user/bank-accounts/#{at_user_bank_account.id}/transactions/", params: params, headers: headers
        response_json = JSON.parse(response.body)
        actual_transactions = response_json['transactions']

        expect(actual_transactions.length).to eq 1
        expect(actual_transactions[0]['at_user_bank_transaction_id']).to eq expect_distributed_transaction.at_user_bank_transaction_id
        expect(actual_transactions[0]['amount']).to eq expect_distributed_transaction.amount
        expect(actual_transactions[0]['used_date']).to eq expect_distributed_transaction.used_date.strftime('%Y-%m-%d %H:%M:%S')
        expect(actual_transactions[0]['used_location']).to eq expect_distributed_transaction.used_location
        expect(actual_transactions[0]['user_id']).to eq expect_distributed_transaction.user_id
        expect(actual_transactions[0]['is_account_shared']).to eq at_user_bank_account.share
        expect(actual_transactions[0]['is_shared']).to eq expect_distributed_transaction.share
        expect(actual_transactions[0]['at_transaction_category_id']).to eq expect_distributed_transaction.at_transaction_category_id
        expect(actual_transactions[0]['category_name1']).to eq expect_distributed_transaction.at_transaction_category.category_name1
        expect(actual_transactions[0]['category_name2']).to eq expect_distributed_transaction.at_transaction_category.category_name2
        expect(actual_transactions[0]['transaction_id']).to eq expect_distributed_transaction.at_user_bank_transaction_id
        expect(response_json['next_transaction_used_date']).to eq nil
      end
    end

    context 'error' do
      it 'response 401' do
        get "/api/v1/user/bank-accounts/#{at_user_bank_account.id}/transactions/"
        expect(response.status).to eq 401
      end
    end
  end
end
