class Api::V1::ActivitiesController < ApplicationController
  before_action :authenticate, except: :login

  def index
    @activities = Entities::Activity.new.activities(
        params[:bank_account_id],
        params[:card_account_id],
        params[:emoney_account_id],
        params[:partner_bank_account_id],
        params[:partner_card_account_id],
        params[:partner_emoney_account_id]
    )
    render 'index', formats: 'json', handlers: 'jbuilder'
  end

end
