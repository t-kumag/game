require 'rails_helper'

RSpec.describe 'bank_transactions_controller' do
  let(:user) { create(:user, :with_at_user_bank_transactions) }
  let(:headers) { { 'Authorization': 'Bearer ' + user.token} }
  let(:params) { { 
    at_transaction_category_id: 1,
    used_location: 'ミロク居酒屋 支払',
    share: false
  } }
  let(:at_user_bank_account) { user.at_user.at_user_bank_accounts.first }
  let(:at_user_bank_transaction) { at_user_bank_account.at_user_bank_transactions.first }
  let(:user_distributed_transaction_after_update) { 
    Entities::UserDistributedTransaction.find_by(at_user_bank_transaction_id: at_user_bank_transaction.id)
  }
  let!(:at_grouped_category) { create(:at_grouped_category) } 
  let!(:at_transaction_category) { create(:at_transaction_category) }

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