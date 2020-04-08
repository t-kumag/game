class Api::V1::Group::PlController < ApplicationController
  before_action :authenticate

  def summary
    @response = Services::PlService.new(@current_user, @category_version, true).pl_summary([1], params[:from], params[:to])
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end

  def categories
    @response = Services::PlService.new(@current_user, @category_version, true).pl_category_summary([1], params[:from], params[:to])
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def grouped_categories
    @response = Services::PlService.new(@current_user, @category_version, true).pl_grouped_category_summary([1], params[:from], params[:to])
    # クライアント側使用感維持のため JSON フォーマットは categories と同様のものを使用する
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
end
