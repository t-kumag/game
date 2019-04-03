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
    @goals = @current_user.groups.find(params[:group_id]).goals
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

  def update
  end

  def destroy
  end
  
  private
  def goal_params(params)
    params.permit(:name, :imageUrl, :startDate, :endDate, :goalAmount, :currentAmount).merge(user_id: @current_user.id, group_id: params[:group_id])
  end
end
