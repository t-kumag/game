require 'rails_helper'

RSpec.describe 'pairing_requests_controller' do
  let(:user) { create(:user) }
  let(:headers) { { Authorization: 'Bearer ' + user.token } }
  
  describe '#generate_pairing_token' do
    let(:pairing_request_after_generate) { Entities::PairingRequest.find_by(from_user_id: user.id) } 

    context 'success' do
      it 'response 200' do
        get '/api/v1/pairing-requests/generate_pairing_token', headers: headers 
        expect(response.status).to eq 200
      end

      it 'token is created' do
        get '/api/v1/pairing-requests/generate_pairing_token', headers: headers 
        json = JSON.parse(response.body)
        expect(json['app']['token']).to eq pairing_request_after_generate.token
      end
      
      it 'token_expires_at is created' do
        get '/api/v1/pairing-requests/generate_pairing_token', headers: headers 
        json = JSON.parse(response.body)
        expect(json['app']['token_expires_at'].to_time).to eq pairing_request_after_generate.token_expires_at.to_time
      end

      it 'status is created with 1' do
        get '/api/v1/pairing-requests/generate_pairing_token', headers: headers 
        expect(pairing_request_after_generate.status).to eq 1
      end

      it 'generate a pairing_requests record' do
        get '/api/v1/pairing-requests/generate_pairing_token', headers: headers
        expect(Entities::PairingRequest.where(from_user_id: user.id)).to exist
      end
    end
  end

  describe '#receive_pairing_request' do
    let(:params) { { 
      pairing_token: pairing_request.token
    } } 
    let!(:partner_user) { create(:user) }
    let(:pairing_request) { create(:pairing_request, from_user_id: user.id, status: 1) }
    let(:pairing_request_after_receive) { Entities::PairingRequest.find_by(to_user_id: partner_user.id) }

    context 'success' do
      it 'response 200' do
        post '/api/v1/pairing-requests/receive_pairing_request', params: params, headers: headers 
        expect(response.status).to eq 200
      end

      it 'status changed from 1 to 2' do
        post '/api/v1/pairing-requests/receive_pairing_request', params: params, headers: headers 
        expect(pairing_request_after_receive.status).to eq 2
      end

      it 'group_id is created' do
        post '/api/v1/pairing-requests/receive_pairing_request', params: params, headers: headers 
        expect(pairing_request_after_receive.group_id).not_to eq nil
      end

      it 'to_user_id is created' do
        post '/api/v1/pairing-requests/receive_pairing_request', params: params, headers: headers 
        expect(pairing_request_after_receive.to_user_id).not_to eq nil
      end

      it 'generate a group record' do
        expect {
          post '/api/v1/pairing-requests/receive_pairing_request', 
          params: params, headers: headers
        }.to change(Entities::Group, :count).by(+1)
      end

      it 'generate two participate_group record' do
        post '/api/v1/pairing-requests/receive_pairing_request', params: params, headers: headers
        expect(Entities::ParticipateGroup.where(user_id: user.id)).to exist
        expect(Entities::ParticipateGroup.where(user_id: partner_user.id)).to exist
      end

      it 'generate two participate_group record' do
        post '/api/v1/pairing-requests/receive_pairing_request', params: params, headers: headers
        expect(Entities::Activity.where(user_id: user.id)).to exist
        expect(Entities::Activity.where(user_id: partner_user.id)).to exist
      end
    end
  end
end