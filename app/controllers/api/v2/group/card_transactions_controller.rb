class Api::V2::Group::CardTransactionsController < ApplicationController
  before_action :authenticate

  def index
    account_id = params[:card_account_id].to_i
    if disallowed_at_card_ids?([account_id], true)
      render_disallowed_financier_ids && return
    end

    @transactions = Services::AtCardTransactionService.new(
        @current_user,
        true,
        params[:from],
        params[:to]
    ).list(account_id)

    render json: {}, status: 200 and return if @transactions.blank?
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def show
    transaction_id = params[:id].to_i
    if disallowed_at_card_transaction_ids?(params[:card_account_id], [transaction_id], true)
      render_disallowed_transaction_ids && return
    end

    @response = Services::AtCardTransactionService.new(@current_user, true).detail(params[:card_account_id], transaction_id)
    render json: {}, status: 200 and return if @response.blank?
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def update
    transaction_id = params[:id].to_i
    if disallowed_at_card_transaction_ids?(params[:card_account_id], [transaction_id], true)
      render_disallowed_transaction_ids && return
    end

    @response = Services::AtCardTransactionService.new(@current_user, true).update(
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
