require 'rails_helper'

describe 'card_accounts_controller' do
  before(:each) do
    @user = create(:user, :with_at_user)
    @headers = { "Authorization" => "Bearer " + @user.token}
  end

  it 'PUT #update' do
    at_user_card_account = create(:at_user_card_account, at_user_id: @user.at_user.id, share: true)
    
    params = {
      "share" => false
    }
    id = at_user_card_account.id
    
    put "/api/v1/user/card-accounts/#{id}", params: params, headers: @headers

    @at_user_card_account = Entities::AtUserCardAccount.find(id)

    expect(@at_user_card_account.share).to eq params["share"]
    expect(response.status).to eq 200
  end

  it 'DELETE #destroy' do
    at_user_card_account = create(:at_user_card_account, at_user_id: @user.at_user.id)
    id = at_user_card_account.id
    
    delete "/api/v1/user/card-accounts/#{id}", headers: @headers
    
    # ↓コメントアウトされたテストは実行する場合、
    # osidori_api/app/models/services/at_user_service.rbの
    # def initialize の10行目と
    # def delete_account の211～216行目をコメントアウトする
    # expect(Entities::AtUserCardAccount.find_by(id: id)).to eq nil
    expect(response.status).to eq 200
  end
end