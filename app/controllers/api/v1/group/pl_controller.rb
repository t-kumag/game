class Api::V1::Group::PlController < ApplicationController
  before_action :authenticate

  def summary
    share = params[:share] == "true" ? [1] : [0,1]
    @response = Services::PlService.new(@current_user,true).pl_summery(share, params[:from])
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end

  def categories
    share = params[:share] == "true" ? [1] : [0,1]
    @response = Services::PlService.new(@current_user,true).pl_category_summery(share, params[:from])
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
end
