class Api::V1::AuthController < ApplicationController
  before_action :authenticate, except: :login
  def login
    puts "login=-====================="
    @user = Entities::User.find_by({email: params[:email]})

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

  def logout
    @current_user.clear_token
    @current_user = nil
    render json: {}, status: 200
  end

end
