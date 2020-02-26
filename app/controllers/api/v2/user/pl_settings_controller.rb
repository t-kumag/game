class Api::V2::User::PlSettingsController < ApplicationController
  before_action :authenticate

  def show
    @response = Entities::UserPlSetting.find_by(user_id: @current_user.id)
    if @response.present?
      render 'show', formats: 'json', handlers: 'jbuilder'
    else
      @response = Entities::UserPlSetting.new(user_id: @current_user.id)
      @response.save!
      render 'no_record', formats: 'json', handlers: 'jbuilder'
    end
  end

  def update
    @response = Entities::UserPlSetting.find_by(user_id: @current_user.id)
    unless @response.present?
      @response = Entities::UserPlSetting.create!(user_id: @current_user.id)
    end
    @response.update!(update_params)

    partner_pl_setting = nil
    if @current_user.partner_user.present?
      partner_pl_setting = Entities::UserPlSetting.find_by(user_id: @current_user.partner_user.id)
    end
    if partner_pl_setting.blank? and @current_user.partner_user.present?
      partner_pl_setting = Entities::UserPlSetting.create!(user_id: @current_user.partner_user.id)
    end
    if @current_user.partner_user.present?
      partner_pl_setting.update!(partner_update_params)
    end

    render json: {}, status: :no_content
  end

  def update_params
    params.require(:pl_settings).permit(:pl_period_date, :pl_type, :group_pl_period_date, :group_pl_type)
  end

  def partner_update_params
    params.require(:pl_settings).permit(:group_pl_period_date, :group_pl_type)
  end
end
