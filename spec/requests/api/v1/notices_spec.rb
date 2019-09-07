require 'rails_helper'

describe 'notices_controller' do
  before(:each) do
    @user = create(:user)
    @headers = { "Authorization" => "Bearer " + @user.token}
  end

  it 'POST #create' do
    params = {
      "title" => "test",
      "date" => "2020/01/01",
      "url" => "https://www.osidori.co/support",
    }

    expect { 
      post "/api/v1/notices", 
      params: params, 
      headers: @headers 
    }.to change(Entities::Notice, :count).by(+1)

    expect(response.status).to eq 200
  end

end