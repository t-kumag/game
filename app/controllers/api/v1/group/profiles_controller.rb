class Api::V1::Group::ProfilesController < ApplicationController
  before_action :authenticate

  def show
    partner_user = @current_user.partner_user
    @profile = partner_user.try(:user_profile)
    @icon    = partner_user.try(:user_icon)
    if partner_user.present?
      render 'show', formats: 'json', handlers: 'jbuilder'
    else
      render json: {}, status: 200
    end
  end
end
