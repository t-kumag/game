require 'rails_helper'

describe 'icon_controller' do
  before(:each) do
    @user = create(:user)
    @headers = { "Authorization" => "Bearer " + @user.token}
  end

  it 'POST #create' do
    params = {
      "img_url" => "test.jpg",
    }
    
    expect { 
      post "/api/v1/user/icon",
      params: params, 
      headers: @headers
    }.to change(Entities::UserIcon, :count).by(+1)
    
    expect(response.status).to eq 200
  end

  it 'PUT #update' do
    create(:user_icon, user_id: @user.id)

    params = {
      "img_url" => "after.jpg",
    }
    
    put "/api/v1/user/icon", params: params, headers: @headers
    
    @user_icon = Entities::UserIcon.find_by(user_id: @user.id)
    
    expect(@user_icon.img_url).to eq params["img_url"]
    expect(response.status).to eq 200
  end

end