require 'rails_helper'

RSpec.describe 'users_controller' do
  let(:user) { create(:user) }
  let(:headers) { { Authorization: 'Bearer ' + user.token } }
  let(:params) { { email: user.email } } 
  let(:user_after_create) { Entities::User.find(user.id) }
  
  describe '#create' do
    let(:params) { { email: 'test1@example.com', password: 'testtest' } } 
    let(:user_after_create) { Entities::User.find_by(email: params[:email]) }
  
    context 'success' do
      it 'response 200' do
        post '/api/v1/users', params: params 
        expect(response.status).to eq 200
      end

      it 'increase one record of users' do
        post '/api/v1/users', params: params
        expect(Entities::User.where(id: user_after_create.id)).to exist
      end

      it 'increase one record of user_profiles' do
        post '/api/v1/users', params: params
        expect(Entities::UserProfile.where(user_id: user_after_create.id)).to exist
      end
    end
  end

  describe '#resend' do
    let(:user) { create(:user, email_authenticated: 0) }

    context 'success' do
      it 'response 200' do
        post '/api/v1/user/resend', params: params, headers: headers 
        expect(response.status).to eq 200
      end
    end
  end

  describe '#change_password_request' do
    context 'success' do
      it 'response 200' do
        post '/api/v1/users/change_password_request', params: params, headers: headers 
        expect(response.status).to eq 200
      end

      it 'user_after_create.token is not equal user.token' do
        post '/api/v1/users/change_password_request', params: params, headers: headers
        expect(user_after_create.token).not_to eq user.token
      end
    end
  end

  describe '#change_password' do
  
    let(:user) { create(:user, password: 'testtest') } 
    let(:params) { { 
      token: user.token,
      password: user.password,
      password_confirm: user.password,
    } } 

    context 'success' do
      it 'response 200' do
        post '/api/v1/users/change_password', params: params, headers: headers 
        expect(response.status).to eq 200
      end

      it 'password_digest is updated' do
        post '/api/v1/users/change_password', params: params, headers: headers
        expect(user_after_create.password_digest).not_to eq user.password_digest
      end
    end
  end
end