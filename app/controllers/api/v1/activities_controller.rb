class Api::V1::ActivitiesController < ApplicationController
  before_action :authenticate, except: :login

#  def create
#    Entities::Activity.add_bank_outcome_individual(Time.now, @current_user.id)
#  end

  def index
    @activities = Entities::Activity.activities(@current_user.id)
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

end
