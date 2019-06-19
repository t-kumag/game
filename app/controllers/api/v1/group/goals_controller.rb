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

  # TODO: 目標編集の仕様確認。内容によって修正対応
  def update
    begin
      Entities::Goal.new.transaction do
        goal = Entities::Goal.find(params[:id])
        goal.update!(get_goal_params)
        Entities::GoalSetting.find(params[:goal_settings][:id]).update!(get_goal_setting_params)
      end

    rescue => exception
      p exception
      render(json: {}, status: 400) && return
    end

    render(json: {}, status: 200)
  end

  # TODO: 要件確認して論理削除にする
  def destroy
    Entities::Goal.find(params[:id]).destroy
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
      :group_id,
      :name,
      :img_url,
      :goal_type_id,
      :start_date,
      :end_date,
      :goal_amount
    ).merge(user_id: @current_user.id, current_amount: 0)
  end
end
