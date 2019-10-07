class Api::V1::ActivitiesController < ApplicationController
  before_action :authenticate, except: :login

  def index
    @activities = Services::ActivityService.fetch_activities(@current_user, params[:page])
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

end
