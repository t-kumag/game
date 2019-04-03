class Api::V1::GroupsController < ApplicationController
  before_action :authenticate

  def index
    # @groups = Entities::Group.all
    # render 'index', formats: 'json', handlers: 'jbuilder'
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
