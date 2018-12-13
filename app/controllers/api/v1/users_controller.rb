class Api::V1::UsersController < ApplicationController
  before_action :authenticate

  def at_url
    @url = Services::AtUserService.new(@current_user).at_url
    render 'at_url', formats: 'json', handlers: 'jbuilder'
  end
end
