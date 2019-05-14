class Api::V1::User::PlController < ApplicationController
  before_action :authenticate

  def summary
    share = params[:share] == "true" ? [1] : [0,1]
    @response = Services::PlService.new(Entities::User.find(@current_user.id)).pl_summery(share, params[:from])
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end

  def categories
    share = params[:share] == "true" ? [1] : [0,1]
    @response = Services::PlService.new(Entities::User.find(@current_user.id)).pl_category_summery(share, params[:from])
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
end
