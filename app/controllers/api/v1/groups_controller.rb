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
end
