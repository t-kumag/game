class Api::V1::ActivitiesController < ApplicationController
  before_action :authenticate, except: :login

  def create
    Entities::Activity.add_bank_outcome_individual(Time.now, @current_user.id, 1)
    Entities::Activity.add_card_outcome_individual(Time.now, @current_user.id, 2)
    Entities::Activity.add_emoney_outcome_individual(Time.now, @current_user.id, 4)
    Entities::Activity.add_bank_outcome_partner(Time.now, 2, @current_user.id, 3)
    Entities::Activity.add_card_outcome_partner(Time.now, 2,@current_user.id, 3)
    Entities::Activity.add_emoney_outcome_partner(Time.now,2 ,@current_user.id, 5)
  end

  def index
    @activities = Entities::Activity.activities(@current_user.id)
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

end
