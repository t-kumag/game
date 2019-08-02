class Api::V1::User::PlController < ApplicationController
  before_action :authenticate

  def summary
    share = params[:share] == "true" ? [1] : [0,1]
    @response = Services::PlService.new(@current_user).pl_summary(share, params[:page],  params[:from], params[:to])
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end

  def categories
    share = params[:share] == "true" ? [1] : [0,1]
    @response = Services::PlService.new(@current_user).pl_category_summary_pagination(share, params[:page])
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def grouped_categories
    share = params[:share] == "true" ? [1] : [0,1]
    @response = Services::PlService.new(@current_user).pl_grouped_category_summary(share, params[:page])
    # クライアント側使用感維持のため JSON フォーマットは categories と同様のものを使用する
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
end
