require 'rails_helper'

RSpec.describe 'users_controller' do
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
    let(:headers) { { Authorization: 'Bearer ' + user.token } }
    let(:params) { { email: 'test1@example.com'} } 

    context 'success' do
      it 'response 200' do
        post '/api/v1/user/resend', params: params, headers: headers 
        expect(response.status).to eq 200
      end
    end
  end
end