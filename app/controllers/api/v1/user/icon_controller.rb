class Api::V1::User::IconController < ApplicationController
  before_action :authenticate

  def create
    begin
      if params[:img_url].present?

        Entities::UserIcon.new.transaction do
          Entities::UserIcon.new(
              img_url: params[:img_url],
              user_id: @current_user.id,
          ).save!
        end

      end
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      p exception
      render(json: {}, status: 400) && return
    end
    render json: {}, status: 200
  end

  def update
    @icon = @current_user.user_icon
    begin
      if @icon.present? &&
          params[:img_url]
        @icon.img_url = params[:img_url]
        @icon.save!
        render json: {}, status: 200
        return
      end
      render json: {}, status: 200
    rescue
      render json: {}, status: 500
    end
  end

  def index
    @icon = Entities::UserIcon.find_by(user_id: @current_user.id)
    render 'index', formats: 'json', handlers: 'jbuilder'
  end
end
