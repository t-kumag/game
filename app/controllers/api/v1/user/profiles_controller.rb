class Api::V1::User::ProfilesController < ApplicationController
  before_action :authenticate

  def create
    return render(json: { errors: { code: '', mesasge: "user profile is registered." } }, status: 422) if @current_user.try(:user_profile)
    begin
      Entities::UserProfile.new(user_profile_params).save!
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
