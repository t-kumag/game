require 'rails_helper'

describe 'card_transactions_controller' do
  before(:each) do
    @user = create(:user, :with_at_user_card_accounts)
    @headers = { "Authorization" => "Bearer " + @user.token}
  end

  it 'PUT #update' do
    create(:at_grouped_category)
    create(:at_transaction_category)
    @at_user_card_account = @user.at_user.at_user_card_accounts.first
    @at_user_card_transaction = create(
      :at_user_card_transaction, 
      at_user_card_account_id: @at_user_card_account.id
    )
    @at_user_card_transaction.user_distributed_transaction = create(
      :user_distributed_transaction, 
      user_id: @user.id, 
      at_user_card_transaction_id: @at_user_card_transaction.id
    )

    params = {
      "at_transaction_category_id" => 1,
      "used_location" => "OsidOri",
      "share" => false
    }
    card_account_id = @at_user_card_account.id
    transaction_id = @at_user_card_transaction.id

    put "/api/v1/user/card-accounts/#{card_account_id}/transactions/#{transaction_id}", params: params, headers: @headers

    @user_distributed_transaction = Entities::UserDistributedTransaction.find_by(user_id: @user.id)

    expect(@user_distributed_transaction.used_location).to eq params["used_location"]

    expect(response.status).to eq 200
  end

end