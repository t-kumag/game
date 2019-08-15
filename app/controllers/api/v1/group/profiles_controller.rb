class Api::V1::Group::ProfilesController < ApplicationController
  before_action :authenticate

  def show
    partner_user = @current_user.try(:partner_user)
    @profile = partner_user.try(:user_profile)
    @icon    = partner_user.try(:user_icon)
    render 'show', formats: 'json', handlers: 'jbuilder'
  end
end
