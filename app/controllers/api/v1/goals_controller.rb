class Api::V1::GoalsController < ApplicationController
  before_action :authenticate

  def index
    @goals = @current_user.groups.find(params[:group_id]).goals
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

  def show
  end

  def create
    Entities::Goal.create(goal_params(params))
    # TODO つくあった目標だけかえせばいい
    @goals = @current_user.groups.find(params[:group_id]).goals
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

  def update
    # TODO 追加金額など更新
    @goals = @current_user.groups.find(params[:group_id]).goals
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

  def destroy
  end
  
  private
  def goal_params(params)
    params.permit(:name, :image_url, :start_date, :end_date, :goal_amount, :current_amount).merge(user_id: @current_user.id, group_id: params[:group_id])
  end
end
