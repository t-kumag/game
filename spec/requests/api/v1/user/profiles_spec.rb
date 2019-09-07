require 'rails_helper'

describe 'profiles_controller' do
  before(:each) do
    @user = create(:user)
    @headers = { "Authorization" => "Bearer " + @user.token}
  end

  it 'POST #create' do
    params = {
      "gender" => 0,
      "birthday" => "2019-01-01",
      "has_child" => 0,
      "push" => true,
    }
    
    expect { 
      post "/api/v1/user/profiles", 
      params: params, 
      headers: @headers 
    }.to change(Entities::UserProfile, :count).by(+1)
    
    expect(response.status).to eq 200
  end

  it 'PUT #update' do
    create(:user_profile, user_id: @user.id)

    params = {
      "gender" => 1,
      "birthday" => "2019-01-01",
      "has_child" => 1,
      "push" => false,
    }
    
    put "/api/v1/user/profiles", params: params, headers: @headers
    
    @user_profile = Entities::UserProfile.find_by(user_id: @user.id)
    
    expect(@user_profile.gender).to eq 1
    expect(@user_profile.has_child).to eq 1
    expect(@user_profile.push).to eq false
    expect(response.status).to eq 200
  end

  it 'GET #show' do
    @user_profile = create(:user_profile, user_id: @user.id)

    get "/api/v1/user/profiles", headers: @headers
    json = JSON.parse(response.body)

    expect(json['app']['user_id']).to eq @user.id
    expect(json['app']['gender']).to eq @user_profile.gender
    expect(json['app']['has_child']).to eq @user_profile.has_child
    expect(json['app']['push']).to eq @user_profile.push
    expect(response.status).to eq 200
  end
end