class Api::V1::UsersController < ApplicationController
  before_action :authenticate

  def at_url
    @response = Services::AtUserService.new(@current_user).at_url
    render 'at_url', formats: 'json', handlers: 'jbuilder'
  end

  def at_sync
    puts "at_sync=========="
    Services::AtUserService.new(@current_user).sync
    obj = {}
    render json: obj, status: 200
  end

end
