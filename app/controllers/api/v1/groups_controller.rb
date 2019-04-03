class Api::V1::GroupsController < ApplicationController
  before_action :authenticate

  def index
    @groups = @current_user.groups
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

  def show
  end

  def create
    if params[:user_id] && params[:group_id]
      @current_user.user_groups.build(user_group_params).save!
      @with_group_user = Entities::User.find(params[:user_id]).user_groups.build(user_group_params).save!
      @groups = @current_user.groups
    elsif @current_user.groups.empty?
      @current_user.groups.create!
      @groups = @current_user.groups
    else
      @groups = @current_user.groups
    end
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

  def update
  end

  def destroy
  end
  
  def user_group_params
    params.permit(:group_id, :user_id)
  end
end
