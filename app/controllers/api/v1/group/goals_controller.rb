# TODO: 遷移図にあわせてグループ目標だけ
# TODO 画像のimg_urlのフォーマットや仕様を決める
# TODO バッチ処理 current_amountへの加算タイミング
# TODO 紐付け口座の変更処理

class Api::V1::Group::GoalsController < ApplicationController
  before_action :authenticate

  def index
    @responses = Entities::Goal.where(user_id: @current_user.id)
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

  def show
    @response = Entities::Goal.find(params[:id])
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def create
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
      p exception
      render(json: {}, status: 400) && return
    end

    render(json: {}, status: 200)
  end

  # TODO: 渡された goal_setting_idがgoalに紐づくものかをチェックする
  def update
    begin
      Entities::Goal.new.transaction do
        goal = Entities::Goal.find(params[:id])
        goal.update!(get_goal_params)
        Entities::GoalSetting.find(params[:goal_settings][:goal_setting_id]).update!(get_goal_setting_params)
      end

    rescue => exception
      p exception
      render(json: {}, status: 400) && return
    end

    render(json: {}, status: 200)
  end

  def destroy
    Entities::Goal.find(params[:id]).destroy
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
    ).merge(group_id: @current_user.group_id, user_id: @current_user.id, current_amount: 0)
  end
end
