require 'rails_helper'

describe 'auth_controller' do
  before(:each) do
    @user = build(:user)
    @user.password = "testtest"
    @user.save!

    @headers = { "Authorization" => "Bearer " + @user.token}
  end

  it 'POST #login' do
    params = {
      "email" => @user.email,
      "password" => @user.password,
    }
    
    post "/api/v1/auth/login", params: params, headers: @headers 
    json = JSON.parse(response.body)

    @user = Entities::User.find(@user.id)
    
    expect(json['app']['access_token']).to eq @user.token
    expect(response.status).to eq 200
  end

  it 'DELETE #logout' do
    delete "/api/v1/auth/logout", headers: @headers
    
    @user = Entities::User.find(@user.id)

    expect(@user.token).to eq nil
    expect(@user.token_expires_at).to eq nil
    expect(response.status).to eq 200
  end
end