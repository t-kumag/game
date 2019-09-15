require 'rails_helper'

describe 'user_manually_created_transactions_controller' do
  before(:each) do
    @user = create(:user)
    @headers = { "Authorization" => "Bearer " + @user.token}
  end

  it 'POST #create' do
    create(:at_grouped_category)
    create(:at_transaction_category)

    params = {
      "at_transaction_category_id" => 1,
      "payment_method_id" => nil,
      "used_date" => "2019/12/31",
      "title" => nil,
      "amount" => 10000,
      "used_location" => "test",
      "share" => false
    }
    
    expect { 
      post "/api/v1/user/user-manually-created-transactions",
      params: params, 
      headers: @headers
    }.to change(Entities::UserManuallyCreatedTransaction, :count).by(+1)

    expect(Entities::UserDistributedTransaction.where(user_id: @user.id)).to exist
    expect(Entities::Activity.where(user_id: @user.id)).to exist
    expect(response.status).to eq 200
  end

  it 'PUT #update' do
    create(:at_grouped_category)
    create(:at_transaction_category)
    user_manually_created_transaction = create(:user_manually_created_transaction, :with_user_distributed_transaction, user_id: @user.id)

    params = {
      "at_transaction_category_id" => 1,
      "payment_method_id" => nil,
      "used_date" => "2019/12/31",
      "title" => nil,
      "amount" => 10000,
      "used_location" => "OsidOri",
      "share" => false
    }
    id = user_manually_created_transaction.id

    put "/api/v1/user/user-manually-created-transactions/#{id}", params: params, headers: @headers

    @user_manually_created_transaction = Entities::UserManuallyCreatedTransaction.find_by(user_id: @user.id)
    @user_distributed_transaction = Entities::UserDistributedTransaction.find_by(user_id: @user.id)

    expect(@user_manually_created_transaction.used_location).to eq params["used_location"]
    expect(@user_distributed_transaction.used_location).to eq params["used_location"]
    expect(Entities::Activity.where(user_id: @user.id)).to exist

    expect(response.status).to eq 200
  end

  it 'DELETE #destroy' do
    create(:at_grouped_category)
    create(:at_transaction_category)
    @user_manually_created_transaction = create(:user_manually_created_transaction, :with_user_distributed_transaction, user_id: @user.id)
    
    id = @user_manually_created_transaction.id

    delete "/api/v1/user/user-manually-created-transactions/#{id}", headers: @headers
    
    expect(Entities::UserManuallyCreatedTransaction.where(user_id: @user.id)).to_not exist
    expect(Entities::UserDistributedTransaction.where(user_id: @user.id)).to_not exist
    expect(Entities::Activity.where(user_id: @user.id)).to_not exist
    expect(response.status).to eq 200
  end
end