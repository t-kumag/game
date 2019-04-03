class Api::V1::GroupsController < ApplicationController
  before_action :authenticate

  def index
    @groups = @current_user.groups
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

  def show
  end

  def create
    if @current_user.groups.empty?
      @group = Entities::Group.create()
      @group.save!
      @userGroup = Entities::UserGroup.create(user_id: @current_user.id, group_id: @group.id)
      @userGroup.save!
      @groups = Entities::Group.where(user_id: @current_user.id)
    else
      @groups = @current_user.groups
    end
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

  def update
  end

  def destroy
  end
end
