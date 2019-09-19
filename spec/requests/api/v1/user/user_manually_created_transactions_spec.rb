require 'rails_helper'

RSpec.describe 'user_manually_created_transactions_controller' do
  let(:user) { create(:user) } 
  let(:headers) { { Authorization: 'Bearer ' + user.token } } 
  let(:params) { { 
    at_transaction_category_id: 1,
    payment_method_id: nil,
    used_date: '2019/12/31',
    title: nil,
    amount: 10000,
    used_location: 'test',
    share: false
  } }
  let!(:at_grouped_category) { create(:at_grouped_category) } 
  let!(:at_transaction_category) { create(:at_transaction_category) }
  let(:user_manually_created_transaction) { 
    create(
      :user_manually_created_transaction, 
      :with_user_distributed_transaction,
      user_id: user.id 
    )
  }
  let(:user_manually_created_transaction_after_update) { 
    Entities::UserManuallyCreatedTransaction.find_by(user_id: user.id) 
  } 
  let(:user_distributed_transaction_after_update) { 
    Entities::UserDistributedTransaction.find_by(user_id: user.id) 
  }

  describe '#create' do
    context 'success' do
      it 'response 200' do
        post '/api/v1/user/user-manually-created-transactions', params: params, headers: headers
        expect(response.status).to eq 200
      end

      it 'increase one record of user_manually_created_transactions' do
        post '/api/v1/user/user-manually-created-transactions', params: params, headers: headers
        expect(Entities::UserManuallyCreatedTransaction.where(user_id: user.id)).to exist
      end

      it 'increase one record of user_distributed_transactions' do
        post '/api/v1/user/user-manually-created-transactions', params: params, headers: headers
        expect(Entities::UserDistributedTransaction.where(user_id: user.id)).to exist
      end

      it 'increase one record of activities' do
        post '/api/v1/user/user-manually-created-transactions', params: params, headers: headers
        expect(Entities::Activity.where(user_id: user.id)).to exist
      end
    end
  end
  
  describe '#update' do
    let(:params) { { 
      at_transaction_category_id: 1,
      payment_method_id: nil,
      used_date: '2019/12/31',
      title: nil,
      amount: 10000,
      used_location: 'sample',
      share: false
    } }

    it 'response 200' do
      put "/api/v1/user/user-manually-created-transactions/#{user_manually_created_transaction.id}",
        params: params, 
        headers: headers
      expect(response.status).to eq 200
    end

    it 'used_location is updated' do
      put "/api/v1/user/user-manually-created-transactions/#{user_manually_created_transaction.id}",
        params: params, 
        headers: headers
      expect(user_manually_created_transaction_after_update.used_location).to eq params[:used_location]
    end

    it 'used_location is updated' do
      put "/api/v1/user/user-manually-created-transactions/#{user_manually_created_transaction.id}",
        params: params, 
        headers: headers
      expect(user_distributed_transaction_after_update.used_location).to eq params[:used_location]
    end

    it 'increase one record of activities' do
      put "/api/v1/user/user-manually-created-transactions/#{user_manually_created_transaction.id}",
        params: params, 
        headers: headers
      expect(Entities::Activity.where(user_id: user.id)).to exist
    end
  end

  describe '#destroy' do
    context 'success' do
      it 'respose 200' do
        delete "/api/v1/user/user-manually-created-transactions/#{user_manually_created_transaction.id}", 
          headers: headers
        expect(response.status).to eq 200
      end
      
      it 'user_manually_created_transaction is nil' do
        delete "/api/v1/user/user-manually-created-transactions/#{user_manually_created_transaction.id}",
          headers: headers
        expect(Entities::UserManuallyCreatedTransaction.find_by(user_id: user.id)).to eq nil
      end
      
      it 'user_distributed_transaction is nil' do
        delete "/api/v1/user/user-manually-created-transactions/#{user_manually_created_transaction.id}",
          headers: headers
        expect(Entities::UserDistributedTransaction.find_by(user_id: user.id)).to eq nil
        end
        
      it 'activity is nil' do
        delete "/api/v1/user/user-manually-created-transactions/#{user_manually_created_transaction.id}",
          headers: headers
        expect(Entities::Activity.find_by(user_id: user.id)).to eq nil
      end
    end
  end
end