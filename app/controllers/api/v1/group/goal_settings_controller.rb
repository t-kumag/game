class Api::V1::Group::GoalSettingsController < ApplicationController
  before_action :authenticate

  def show
    if disallowed_goal_setting_ids?(params[:goal_id], [params[:id].to_i], true)
      render_disallowed_goal_setting_ids && return
    end
    @response = Entities::GoalSetting.find(params[:id])
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def create
    if disallowed_goal_ids?([params[:goal_id].to_i], true)
      render_disallowed_goal_ids && return
    end

    if Entities::Goal.find(params[:goal_id]).blank?
      render json: { errors: ERROR_TYPE::NUMBER['005004'] }, status: 422
    end
    if get_goal_setting_params[:at_user_bank_account_id].present? &&
        disallowed_at_bank_ids?([get_goal_setting_params[:at_user_bank_account_id].to_i], true)
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
    if disallowed_goal_setting_ids?(params[:goal_id], [params[:id].to_i], true)
      render_disallowed_goal_setting_ids && return
    end

    if Entities::Goal.find(params[:goal_id]).blank?
      render json: { errors: ERROR_TYPE::NUMBER['005004'] }, status: 422
    end
    p get_goal_setting_params[:at_user_bank_account_id]
    if disallowed_at_bank_ids?([get_goal_setting_params[:at_user_bank_account_id].to_i], true)
      return render_disallowed_financier_ids
    end

    goal_setting = Entities::GoalSetting.find(params[:id])
    if goal_setting.blank?
      render json: { errors: ERROR_TYPE::NUMBER['005005'] }, status: 422
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
    ).merge(user_id: @current_user.id)
  end
end
