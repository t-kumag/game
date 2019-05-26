class Api::V1::User::PlController < ApplicationController
  before_action :authenticate

  def summary
    share = params[:share] == "true" ? [1] : [0,1]
    @response = Services::PlService.new(@current_user).pl_summery(share, params[:from])
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end

  def categories
    share = params[:share] == "true" ? [1] : [0,1]
    @response = Services::PlService.new(@current_user).pl_category_summery(share, params[:from])
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def grouped_categories
    share = params[:share] == "true" ? [1] : [0,1]
    @response = Services::PlService.new(@current_user).pl_grouped_category_summary(share, params[:from])
    # APP 使用感維持のため JSON フォーマットは categories と同様のものを使用する 
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
end
