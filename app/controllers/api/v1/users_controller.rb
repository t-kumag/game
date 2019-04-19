class Api::V1::UsersController < ApplicationController
  before_action :authenticate, only: [:at_url, :at_sync]
  def sign_up_params
    params.require(:user).permit(:email, :password)
  end

  def create
    @user = Entities::User.new()
    @user.email = sign_up_params[:email]
    @user.password = sign_up_params[:password]
    @user.email_authenticated = false
    @user.reset_token
    @user.save!
    render 'create', formats: 'json', handlers: 'jbuilder', status: 200
  end

  def at_url
    @response = Services::AtUserService.new(@current_user).at_url
    render 'at_url', formats: 'json', handlers: 'jbuilder'
  end

  def at_sync
    puts "at_scraping==========1"
    Services::AtUserService.new(@current_user).exec_scraping
    puts "at_sync=========="
    Services::AtUserService.new(@current_user).sync
    obj = {}
    render json: obj, status: 200
  end

end
