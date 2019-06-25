class Api::V1::User::ProfilesController < ApplicationController
  before_action :authenticate

  def create
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
    if @profile.present? 
      render 'index', formats: 'json', handlers: 'jbuilder'
    else
      render json: {}, status: 200
    end  
  end

  private

  def user_profile_params
    params.permit(
        :gender,
        :birthday,
        :has_child,
        :push
    ).merge(
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

