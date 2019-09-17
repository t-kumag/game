require 'rails_helper'

describe 'users_controller' do
  it 'POST #create' do
    params = {
      "email" => "test1@example.com",
      "password" => "testtest"
    }

    expect { 
      post "/api/v1/users", 
      params: params,
      headers: @headers 
    }.to change(Entities::User, :count).by(+1)

    @user = Entities::User.find_by(email: params["email"])
    expect(Entities::UserProfile.where(user_id: @user.id)).to exist
    expect(response.status).to eq 200
  end

  it 'POST #resend' do
    @user = create(:user, email_authenticated: 0)
    @headers = { "Authorization" => "Bearer " + @user.token}

    params = {
      "email" => @user.email
    }
    
    post "/api/v1/user/resend", params: params, headers: @headers 
    expect(response.status).to eq 200
  end

end