require 'rails_helper'

RSpec.describe 'auth_controller' do
  let(:user) { create(:user) } 
  let(:headers) { { Authorization: 'Bearer ' + user.token } } 
  let(:params) { { email: user.email, password: user.password } } 
  let(:user_after_logout) { Entities::User.find(user.id) }

  describe '#login' do
    let(:user) { create(:user, password: 'testtest') } 
    
    context 'success' do
      it 'response 200' do
        post '/api/v1/auth/login', params: params, headers: headers
        expect(response.status).to eq 200
      end
      
      it 'token is updated' do
        post '/api/v1/auth/login', params: params, headers: headers 
        json = JSON.parse(response.body)
        expect(json['app']['access_token']).to eq user_after_logout.token
      end
    end
  end

  describe '#logout' do
    context 'success' do
      it 'response 200' do
        delete '/api/v1/auth/logout', headers: headers
        expect(response.status).to eq 200
      end

      it 'token is nil' do
        delete '/api/v1/auth/logout', headers: headers
        expect(user_after_logout.token).to eq nil
      end

      it 'token_expires_at is nil' do
        delete '/api/v1/auth/logout', headers: headers
        expect(user_after_logout.token_expires_at).to eq nil
      end
    end
  end
end