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

    @exist_card_transaction = Services::AtCardTransactionService.new(@current_user).detail(params[:card_account_id], transaction_id)
    card_account_transaction_param = get_card_account_transaction_param(params, transaction_id, @exist_card_transaction)

    @response = Services::AtCardTransactionService.new(@current_user).update(
        card_account_transaction_param[:card_account_id],
        card_account_transaction_param[:transaction_id],
        card_account_transaction_param[:at_transaction_category_id],
        card_account_transaction_param[:used_location],
        card_account_transaction_param[:share],
        card_account_transaction_param[:group_id],
    )

    render json: {}, status: 200 and return if @response.blank?
    render 'update', formats: 'json', handlers: 'jbuilder'
  end

  def get_card_account_transaction_param(params, transaction_id, exist_transaction)
    at_transaction_category_id = params[:at_transaction_category_id].present? ?
                                     params[:at_transaction_category_id] : exist_transaction[:at_transaction_category_id]
    used_location = params[:used_location].present? ? params[:used_location] : exist_transaction[:used_location]
    share = params[:share].present? ? params[:share] : false

    {
        card_account_id: params[:card_account_id],
        transaction_id: transaction_id,
        at_transaction_category_id: at_transaction_category_id,
        used_location: used_location,
        share: share,
        group_id: share ? @current_user.group_id : nil
    }
  end
end
