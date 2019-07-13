class Api::V1::Group::GoalsController < ApplicationController
  before_action :authenticate, :require_group

  def index
    # TODO: 自分のgoal_settingsだけを返す。相手のaccount_idが見えてしまうため
    # TODO: グループのgoalは参照できるが相手ののgoal_settingsは参照できない状態
    @responses = Entities::Goal.where(group_id: @current_user.group_id)
    render(json: { errors: { code: '', mesasge: "Record not found." } }, status: 422) and return if @responses.blank?
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

  def show
    # TODO: 自分のgoal_settingsだけを返す。相手のaccount_idが見えてしまうため
    # TODO: グループのgoalは参照できるが相手ののgoal_settingsは参照できない状態
    @response = Entities::Goal.find_by(id: params[:id], group_id: @current_user.group_id)
    render(json: { errors: { code: '', mesasge: "Record not found." } }, status: 422) and return if @response.blank?
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def create
    if disallowed_at_bank_ids?([get_goal_setting_params[:at_user_bank_account_id]])
      return render_disallowed_financier_ids
    end

    goal_params = get_goal_params
    begin
      goal_type = Entities::GoalType.find(goal_params[:goal_type_id]) unless goal_params[:goal_type_id].nil?
      Entities::Goal.new.transaction do
        goal_params[:name] = goal_type[:name] if goal_params[:name].blank?
        goal_params[:img_url] = goal_type[:img_url] if goal_params[:img_url].blank?
        goal = Entities::Goal.create!(goal_params)
        goal.goal_settings.create!(get_goal_setting_params)
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

  private

  def get_goal_setting_params
    params.require(:goal_settings).permit(
      :at_user_bank_account_id,
      :monthly_amount,
      :first_amount
    )
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
