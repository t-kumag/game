class Api::V1::User::TransactionsController < ApplicationController
  before_action :authenticate

  def index
    @response = Services::TransactionService.new(@current_user.id, params[:from], params[:to], params[:category_id]).list
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def grouped_transactions
    @response = Services::TransactionService.new(@current_user.id, params[:from], params[:to], params[:category_id]).grouped
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
end
