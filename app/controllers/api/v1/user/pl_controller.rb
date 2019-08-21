class Api::V1::User::PlController < ApplicationController
  before_action :authenticate

  def summary
    share = params[:share] == "true" ? [0,1] : [0]
    @response = Services::PlService.new(@current_user).pl_summary(share, params[:from], params[:to])
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end

  def categories
    share = params[:share] == "true" ? [0,1] : [0]
    @response = Services::PlService.new(@current_user).pl_category_summary(share, params[:from], params[:to])
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def grouped_categories
    share = params[:share] == "true" ? [0,1] : [0]
    @response = Services::PlService.new(@current_user).pl_grouped_category_summary(share, params[:from], params[:to])
    # クライアント側使用感維持のため JSON フォーマットは categories と同様のものを使用する
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
end