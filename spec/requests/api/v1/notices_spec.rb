require 'rails_helper'

RSpec.describe 'notices_controller' do
  let(:user) { create(:user) } 
  let(:headers) { { Authorization: 'Bearer ' + user.token } } 
  let(:params) { { title: 'test', date: '2020/01/01', url: 'https://www.osidori.co/support' } } 
  
  describe '#create' do
    context 'success' do
      it 'response 200' do
        post '/api/v1/notices', params: params, headers: headers 
        expect(response.status).to eq 200
      end

      it 'increase one record of notices' do
        expect { 
          post '/api/v1/notices', 
          params: params, 
          headers: headers 
        }.to change(Entities::Notice, :count).by(+1)
      end
    end
  end
end