class Api::V1::AuthController < ApplicationController
  def login
    puts "login=-====================="
    @user = User.find_by({email: params[:email]})
    if @user && @user.authenticate(params[:password])
      @user.reset_token
      @user.save!
      render 'login', formats: 'json', handlers: 'jbuilder'
    else
      render json: {}, status: :unauthorized
    end  
  end

  def authenticate_email
    
  end

end
