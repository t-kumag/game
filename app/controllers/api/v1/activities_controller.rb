class Api::V1::ActivitiesController < ApplicationController
  before_action :authenticate, except: :login

  def index
    @activities = Entities::Activity.activities(@current_user.id)
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

end
