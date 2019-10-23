require 'rails_helper'

RSpec.describe 'bank_transactions_controller' do
  let(:user) { create(:user, :with_at_user_bank_transactions) }
  let(:headers) { { 'Authorization': 'Bearer ' + user.token} }
  let(:params) { {
    at_transaction_category_id: 1,
    used_location: 'ミロク居酒屋 支払',
    share: false
  } }
  let(:find_params) { {
    from: '2018-12-31',
    to: '2019-01-01'
  } }
  let(:at_user_bank_account) { user.at_user.at_user_bank_accounts.first }
  let(:at_user_bank_transaction) { at_user_bank_account.at_user_bank_transactions.first }
  let(:user_distributed_transaction_after_update) {
    Entities::UserDistributedTransaction.find_by(at_user_bank_transaction_id: at_user_bank_transaction.id)
  }
  let!(:at_grouped_category) { create(:at_grouped_category) }
  let!(:at_transaction_category) { create(:at_transaction_category) }

  describe '#show' do
    context 'success' do
      it 'response 200' do
        get "/api/v1/user/bank-accounts/#{at_user_bank_account.id}/transactions/#{at_user_bank_transaction.id}", headers: headers
        expect(response.status).to eq 200
      end

      it 'response json' do
        expect_bank_transaction = at_user_bank_transaction
        expeted_distributed_transaction = expect_bank_transaction.user_distributed_transaction

        get "/api/v1/user/bank-accounts/#{at_user_bank_account.id}/transactions/#{at_user_bank_transaction.id}", headers: headers
        response_json = JSON.parse(response.body)
        actual_app = response_json['app']

        expect(actual_app['amount']).to eq expeted_distributed_transaction.amount
        # trade_dateか要確認
        expect(actual_app['used_date']).to eq expect_bank_transaction.trade_date.strftime('%Y-%m-%d %H:%M:%S')
        expect(actual_app['used_location']).to eq expeted_distributed_transaction.used_location
        expect(actual_app['user_id']).to eq expeted_distributed_transaction.user_id
        expect(actual_app['is_account_shared']).to eq at_user_bank_account.share
        expect(actual_app['is_shared']).to eq expeted_distributed_transaction.share
        expect(actual_app['at_transaction_category_id']).to eq expeted_distributed_transaction.at_transaction_category_id
        expect(actual_app['category_name1']).to eq expeted_distributed_transaction.at_transaction_category.category_name1
        expect(actual_app['category_name2']).to eq expeted_distributed_transaction.at_transaction_category.category_name2
        expect(actual_app['transaction_id']).to eq expeted_distributed_transaction.at_user_bank_transaction_id
      end
    end
  end

  describe '#update' do
    context 'success' do
      it 'response 200' do
        put "/api/v1/user/bank-accounts/#{at_user_bank_account.id}/transactions/#{at_user_bank_transaction.id}",
          params: params, headers: headers
          expect(response.status).to eq 200
      end

      it 'used_location is updated' do
        put "/api/v1/user/bank-accounts/#{at_user_bank_account.id}/transactions/#{at_user_bank_transaction.id}",
          params: params, headers: headers
        expect(user_distributed_transaction_after_update.used_location).to eq params[:used_location]
      end
    end
  end
end
