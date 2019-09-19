require 'rails_helper'

RSpec.describe 'card_accounts_controller' do
  let(:user) { create(:user, :with_at_user) }
  let(:headers) { { Authorization: 'Bearer ' + user.token} }
  let(:params) { { share: false} }
  let(:at_user_card_account) { create(:at_user_card_account, at_user_id: user.at_user.id, share: true) }

  describe '#update' do
    let(:at_user_card_account_after_update) { Entities::AtUserCardAccount.find(at_user_card_account.id) }

    context 'success' do
      it 'response 200' do
        put "/api/v1/user/card-accounts/#{at_user_card_account.id}", params: params, headers: headers
        expect(response.status).to eq 200
      end

      it 'share is updated' do
        put "/api/v1/user/card-accounts/#{at_user_card_account.id}", params: params, headers: headers
        expect(at_user_card_account_after_update.share).to eq params[:share]
      end
    end
  end

  describe '#destroy' do
    context 'success' do
      it 'response 200' do
        delete "/api/v1/user/card-accounts/#{at_user_card_account.id}", headers: headers
        expect(response.status).to eq 200
      end
      
      # 口座削除のテストは実行する場合、
      # osidori_api/app/models/services/at_user_service.rbの
      # def initialize の10行目と def delete_account の211～216行目をコメントアウト
      # it 'at_user_card_account is nil' do
      #  delete "/api/v1/user/card-accounts/#{at_user_card_account.id}", headers: headers
      #  expect(Entities::AtUserCardAccount.find_by(id: at_user_card_account.id)).to eq nil
      # end
    end
  end
end