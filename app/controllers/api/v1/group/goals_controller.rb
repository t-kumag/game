class Api::V1::Group::GoalsController < ApplicationController
  before_action :authenticate, :require_group

  def index
    @responses = Entities::Goal.where(group_id: @current_user.group_id)
    render(json: { errors: { code: '', mesasge: "Record not found." } }, status: 422) and return if @responses.blank?
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

  def show
    @response = Services::GoalService.new(@current_user).get_goal_one(params[:id])
    render(json: { errors: { code: '', mesasge: "Record not found." } }, status: 422) and return if @response.blank?

    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def create

    if get_goal_setting_params[:at_user_bank_account_id].present? &&
        disallowed_at_bank_ids?([get_goal_setting_params[:at_user_bank_account_id]])
      return render_disallowed_financier_ids
    end

    return render json: { errors: { code: '', message: "five goal limit of free users" } }, status: 422  if Services::GoalService.check_goal_limit_of_free_user

    goal_params = get_goal_params
    begin
      goal_type = Entities::GoalType.find(goal_params[:goal_type_id]) unless goal_params[:goal_type_id].nil?
      Entities::Goal.new.transaction do
        goal_params[:name] = goal_type[:name] if goal_params[:name].blank?
        goal_params[:img_url] = goal_type[:img_url] if goal_params[:img_url].blank?
        goal = Entities::Goal.create!(goal_params)
        # 自分の目標設定を登録
        goal.goal_settings.create!(get_goal_setting_params)
        # 相手の目標設定を登録
        goal.goal_settings.create!(get_partner_goal_setting_params)
      end
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      raise exception
    end

    render(json: {}, status: 200)
  end

  def update
    if disallowed_at_bank_ids?([get_goal_setting_params[:at_user_bank_account_id]])
      return render_disallowed_financier_ids
    end

    goal = Entities::Goal.find_by(id: params[:id], group_id: @current_user.group_id)
    render json: { errors: { code: '', mesasge: "Goal not found." } }, status: 422 and return if goal.blank?
    goal_setting = Entities::GoalSetting.find_by(id: params[:goal_settings][:goal_setting_id])
    render json: { errors: { code: '', mesasge: "Goal settings not found." } }, status: 422 and return if goal_setting.blank?

    begin
      ActiveRecord::Base.transaction do
        goal.update!(get_goal_params)
        goal_setting.update!(get_goal_setting_params)
      end
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      raise exception
    end

    render(json: {}, status: 200)
  end

  def destroy
    goal = Entities::Goal.find_by(id: params[:id], group_id: @current_user.group_id)
    if goal.blank?
      render json: { errors: { code: '', mesasge: "Goal not found." } }, status: 422 and return
    end
    begin
      goal.destroy
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      raise exception
    end

    render(json: {}, status: 200)
  end

  def graph
    return render_404 if params[:id].blank?
    @responses = Services::GoalGraphService.new(@current_user, Entities::Goal.find(params[:id]), params[:span]).call
    render 'graph', formats: 'json', handlers: 'jbuilder'
  end

  def add_money
    # TODO:パートナーの追加入金の動作検証　パートナーの目標設定作成IF完成後に動作検証する
    current_user_banks = @current_user.at_user.at_user_bank_accounts.pluck(:at_bank_id)
    goal = Entities::Goal.find_by(id: params[:id], group_id: @current_user.group_id)
    goal_setting = goal.goal_settings.find_by(at_user_bank_account_id: current_user_banks)

    if current_user_banks.blank? || goal.blank? || goal_setting.blank? 
      render(json: {errors: [{code:"", message:"user not found or goal not found"}]}, status: 422) && return
    end
    
    goal_service = Services::GoalService.new(@current_user)
    if goal_service.check_bank_balance(params[:add_amount], goal_setting)
      goal_service.add_money(goal, goal_setting, params[:add_amount])
      render(json: {}, status: 200)
    else
      render(json: {errors: [{code:"", message:"minus balance"}]}, status: 422)
    end
  end

  private

  def get_goal_setting_params
    params.require(:goal_settings).permit(
      :at_user_bank_account_id,
      :monthly_amount,
      :first_amount
    ).merge(user_id: @current_user.id)
  end

  def get_partner_goal_setting_params
    params.require(:partner_goal_settings).permit(
      :monthly_amount,
      :first_amount
    ).merge(user_id: @current_user.partner_user.id)
  end

  def get_goal_params
    params.require(:goals).permit(
      :name,
      :img_url,
      :goal_type_id,
      :start_date,
      :end_date,
      :goal_amount
    ).merge(group_id: @current_user.group_id, user_id: @current_user.id)
  end

end
