class Api::V1::GoalsController < ApplicationController
  before_action :authenticate

  def index
    @goals = @current_user.groups.find(params[:group_id]).goals
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

  def show
  end

  def create
  end

  def update
  end

  def destroy
  end
end
