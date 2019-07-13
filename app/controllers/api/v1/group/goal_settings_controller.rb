class Api::V1::Group::GoalSettingsController < ApplicationController
  before_action :authenticate

  def show
    @response = Entities::GoalSetting.find(params[:id])
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def create
    if Entities::Goal.find(params[:goal_id]).blank?
      render json: { errors: { code: '', mesasge: "goal not found." } }, status: 422
    end
    if disallowed_at_bank_ids?([get_goal_setting_params[:at_user_bank_account_id]])
      return render_disallowed_financier_ids
    end

    begin
      Entities::GoalSetting.create!(get_goal_setting_params)
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      raise exception
    end
    render(json: {}, status: 200)
  end

  def update
    if Entities::Goal.find(params[:goal_id]).blank?
      render json: { errors: { code: '', mesasge: "goal not found." } }, status: 422
    end
    if disallowed_at_bank_ids?([get_goal_setting_params[:at_user_bank_account_id]])
      return render_disallowed_financier_ids
    end

    goal_setting = Entities::GoalSetting.find(params[:id])
    if goal_setting.blank?
      render json: { errors: { code: '', mesasge: "goal_setting not found." } }, status: 422
    end

    begin
      goal_setting.update!(get_goal_setting_params)
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      raise exception
    end
    render(json: {}, status: 200)
  end

  private

  def get_goal_setting_params
    params.permit(
      :goal_id,
      :at_user_bank_account_id,
      :monthly_amount,
      :first_amount
    )
  end
end
