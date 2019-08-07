class Api::V1::User::TransactionsController < ApplicationController
  before_action :authenticate

  def index
    @response = Services::TransactionService.new(@current_user, params[:category_id], params[:share], false, params[:page], params[:from], params[:to]).list
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def grouped_transactions
    @response = Services::TransactionService.new(@current_user, params[:category_id], params[:share], false, params[:page], params[:from], params[:to]).grouped
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
end
