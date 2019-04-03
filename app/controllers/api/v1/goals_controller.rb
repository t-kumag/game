class Api::V1::GoalsController < ApplicationController
  before_action :authenticate

  def index
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
