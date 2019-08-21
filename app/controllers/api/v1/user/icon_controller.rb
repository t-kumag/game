class Api::V1::User::IconController < ApplicationController
  before_action :authenticate

  def create
    if @current_user.user_icon.present?
      render(json: { errors: { code: '', mesasge: "icon is registered." } }, status: 422) && return
    end

    begin
      if params[:img_url].present?

        Entities::UserIcon.new.transaction do
          Entities::UserIcon.new(
            img_url: params[:img_url],
            user_id: @current_user.id
          ).save!
        end

      end
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue
      render(json: {}, status: 400) && return
    end
    render json: {}, status: 200
  end

  def update
    @icon = @current_user.user_icon
    render json: { errors: { code: '', mesasge: "icon not found." } }, status: 422 unless @icon.present?
    @icon.img_url = params.permit(:img_url)[:img_url]
    @icon.save!
    render json: {}
  end

  def index
    @icon = Entities::UserIcon.find_by(user_id: @current_user.id)
    render json: { errors: { code: '', mesasge: "icon not found." } }, status: 422 unless @icon.present?
    render 'index', formats: 'json', handlers: 'jbuilder'
  end
end