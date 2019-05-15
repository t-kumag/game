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

  private

  def user_profile_params
    params.permit(
        :gender,
        :birthday,
        :has_child
    ).merge(
        user_id: @current_user.id
    )
  end
end

