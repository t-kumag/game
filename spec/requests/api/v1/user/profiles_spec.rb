require 'rails_helper'

RSpec.describe 'profiles_controller' do
  let(:user) { create(:user) } 
  let(:headers) { { Authorization: 'Bearer ' + user.token } } 
  let(:params) { { 
    gender: 0, 
    birthday: '2019-01-01',
    has_child: 0, 
    push: true
  } } 
  let(:user_profile_after_update) { Entities::UserProfile.find_by(user_id: user.id) }
  
  describe '#create' do
    context 'success' do
      it 'response 200' do
        post '/api/v1/user/profiles', params: params, headers: headers 
        expect(response.status).to eq 200
      end

      it 'increase one record of profile' do
        post '/api/v1/user/profiles', params: params, headers: headers 
        expect(Entities::UserProfile.where(user_id: user.id)).to exist
      end
    end
  end

  describe '#update' do
    let(:params) { { 
      gender: 1, 
      birthday: '2019-01-01',
      has_child: 1, 
      push: false
    } }
    let!(:user_profile) { create(:user_profile, user_id: user.id) }

    context 'success' do
      it 'response 200' do
        put '/api/v1/user/profiles', params: params, headers: headers
        expect(response.status).to eq 200
      end

      it 'gender is updated' do
        put '/api/v1/user/profiles', params: params, headers: headers
        expect(user_profile_after_update.gender).to eq params[:gender]
      end

      it 'has_child is updated' do
        put '/api/v1/user/profiles', params: params, headers: headers
        expect(user_profile_after_update.has_child).to eq params[:has_child]
      end
      
      it 'push is updated' do
        put '/api/v1/user/profiles', params: params, headers: headers
        expect(user_profile_after_update.push).to eq params[:push]
      end
    end
  end

  describe '#show' do
    let!(:user_profile) { create(:user_profile, user_id: user.id) }

    context 'success' do
      it 'response 200' do
        get '/api/v1/user/profiles', headers: headers
        expect(response.status).to eq 200
      end

      it 'user_id is user.id' do
        get '/api/v1/user/profiles', headers: headers
        json = JSON.parse(response.body)
        expect(json['app']['user_id']).to eq user.id
      end

      it 'gender is user_profile.gender' do
        get '/api/v1/user/profiles', headers: headers
        json = JSON.parse(response.body)
        expect(json['app']['gender']).to eq user_profile.gender
      end
      
      it 'has_child is user_profile.has_child' do
        get '/api/v1/user/profiles', headers: headers
        json = JSON.parse(response.body)
        expect(json['app']['has_child']).to eq user_profile.has_child
      end

      it 'push is user_profile.push' do
        get '/api/v1/user/profiles', headers: headers
        json = JSON.parse(response.body)
        expect(json['app']['push']).to eq user_profile.push
      end
    end
  end
end