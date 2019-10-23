require 'rails_helper'

RSpec.describe Api::V1::Group::CardTransactionsController do
  let(:user) { create(:user, :with_at_user_card_transactions) }
  let(:headers) { { Authorization: 'Bearer ' + user.token} }
  let(:params) { { 
    at_transaction_category_id: 1,
    used_location: 'ミロク居酒屋 支払',
    share: false
  } }
  let(:at_user_card_account) { user.at_user.at_user_card_accounts.first }
  let(:at_user_card_transaction) { at_user_card_account.at_user_card_transactions.first }
  let!(:at_grouped_category) { create(:at_grouped_category) } 
  let!(:at_transaction_category) { create(:at_transaction_category) }

  describe '#update' do
    before do
      at_user_card_account.share = true
      at_user_card_account.save!
    end

    context 'success' do
      it 'response 200' do
        put "/api/v1/group/card-accounts/#{at_user_card_account.id}/transactions/#{at_user_card_transaction.id}", 
          params: params, headers: headers
          expect(response.status).to eq 200
      end
    end
  end
end