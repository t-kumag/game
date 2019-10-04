class Api::V1::User::ProfilesController < ApplicationController
  before_action :authenticate

  def create
    begin
      if @current_user.try(:user_profile).present?
        @current_user.user_profile.update!(get_profile_params)
      else
        Entities::UserProfile.new(user_profile_params).save!
      end
    rescue ActiveRecord::RecordInvalid => db_err
      p db_err
      render(json: {}, status: 400) && return
    rescue => exception
      p exception
      render(json: {}, status: 400) && return
    end
    render json: {}, status: 200
  end

  def update
    begin
      @current_user.user_profile.update!(get_profile_params)
    rescue ActiveRecord::RecordInvalid => db_err
      p db_err
      render(json: {}, status: 400) && return
    rescue => exception
      p exception
      render(json: {}, status: 400) && return
    end
    render json: {}, status: 200
  end

  def show
    @profile = @current_user.user_profile
    @icon    = @current_user.user_icon
    @partner = @current_user.partner_user.present? ?  @current_user.partner_user.id : nil
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  private

  def user_profile_params
    get_profile_params.merge(
      user_id: @current_user.id
    )
  end

  def get_profile_params
    params.permit(
      :gender,
      :birthday,
      :has_child,
      :push
    )
  end
end
