require 'rails_helper'

RSpec.describe 'icon_controller' do
  let(:user) { create(:user) } 
  let(:headers) { { Authorization: 'Bearer ' + user.token } } 
  let(:params) { { img_url: 'test.jpg' } } 
  
  describe '#create' do
    context 'success' do
      it 'response 200' do
        post '/api/v1/user/icon', params: params, headers: headers
        expect(response.status).to eq 200
      end
  
      it 'increase one record of user_icons' do
        post '/api/v1/user/icon', params: params, headers: headers
        expect(Entities::UserIcon.where(user_id: user.id)).to exist
      end
    end
  end
  
  describe '#update' do
    let(:user_icon_after_update) { Entities::UserIcon.find_by(user_id: user.id) }

    context 'success' do
      let(:params) { { img_url: 'sample.jpg' } } 
      let!(:user_icon) { create(:user_icon, user_id: user.id) } 

      it 'response 200' do
        put '/api/v1/user/icon', params: params, headers: headers
        expect(response.status).to eq 200
      end

      it 'img_url is updated' do
        put '/api/v1/user/icon', params: params, headers: headers
        expect(user_icon_after_update.img_url).to eq params[:img_url]
      end
    end
  end
end