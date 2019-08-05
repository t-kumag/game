class Api::V1::User::CardTransactionsController < ApplicationController
  before_action :authenticate

  def index
    @transactions = Services::AtCardTransactionService.new(@current_user, false).list(params[:card_account_id], params[:page])
    @categories   = Entities::AtTransactionCategory.all
    render json: {}, status: 200 and return if @transactions.blank?
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def show
    @response = Services::AtCardTransactionService.new(@current_user).detail(params[:card_account_id], params[:id])
    render json: {}, status: 200 and return if @response.blank?
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def update
    @response = Services::AtCardTransactionService.new(@current_user).update(
        params[:card_account_id], 
        params[:id],
        params[:at_transaction_category_id],
        params[:used_location],
        params[:share],
        params[:share] ? @current_user.group_id : nil
    )
    render json: {}, status: 200 and return if @response.blank?

    render 'update', formats: 'json', handlers: 'jbuilder'
  end

end
