class Api::V1::User::CardTransactionsController < ApplicationController
  before_action :authenticate

  def index
    account_id = params[:card_account_id].to_i
    if disallowed_at_card_ids?([account_id])
      render_disallowed_financier_ids && return
    end

    @transactions = Services::AtCardTransactionService.new(@current_user, false).list(account_id, params[:page])

    @categories   = Entities::AtTransactionCategory.all
    render json: {}, status: 200 and return if @transactions.blank?
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def show
    transaction_id = params[:id].to_i
    if disallowed_at_card_transaction_ids?(params[:card_account_id], [transaction_id])
      render_disallowed_transaction_ids && return
    end

    @response = Services::AtCardTransactionService.new(@current_user).detail(params[:card_account_id], transaction_id)
    render json: {}, status: 200 and return if @response.blank?
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def update
    transaction_id = params[:id].to_i
    if disallowed_at_card_transaction_ids?(params[:card_account_id], [transaction_id])
      render_disallowed_transaction_ids && return
    end
    @response = Services::AtCardTransactionService.new(@current_user).update(
        params[:card_account_id], 
        transaction_id,
        params[:at_transaction_category_id],
        params[:used_location],
        params[:share],
        params[:share] ? @current_user.group_id : nil
    )
    render json: {}, status: 200 and return if @response.blank?

    render 'update', formats: 'json', handlers: 'jbuilder'
  end

end
