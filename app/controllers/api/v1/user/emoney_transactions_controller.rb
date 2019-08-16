class Api::V1::User::EmoneyTransactionsController < ApplicationController
  before_action :authenticate

  def index
    account_id = params[:emoney_account_id].to_i
    render_disallowed_financier_ids && return if disallowed_at_emoney_ids?([account_id])

    @transactions = Services::AtEmoneyTransactionService.new(@current_user, false).list(account_id, params[:page])
    @categories   = Entities::AtTransactionCategory.all
    render json: {}, status: 200 and return if @transactions.blank?
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def show
    transaction_id = params[:id].to_i
    if disallowed_at_emoney_transaction_ids?(params[:emoney_account_id], [transaction_id])
      render_disallowed_transaction_ids && return
    end

    @response = Services::AtEmoneyTransactionService.new(@current_user).detail(params[:emoney_account_id], transaction_id)
    render json: {}, status: 200 and return if @response.blank?
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def update
    transaction_id = params[:id].to_i
    if disallowed_at_emoney_transaction_ids?(params[:emoney_account_id], [transaction_id])
      render_disallowed_transaction_ids && return
    end

    @exist_transaction = Services::AtEmoneyTransactionService.new(@current_user).detail(params[:emoney_account_id], transaction_id)
    emoney_account_transaction_param = get_emoney_account_transaction_param(params, transaction_id, @exist_transaction)

    @response = Services::AtEmoneyTransactionService.new(@current_user).update(
        emoney_account_transaction_param[:emoney_account_id],
        emoney_account_transaction_param[:transaction_id],
        emoney_account_transaction_param[:at_transaction_category_id],
        emoney_account_transaction_param[:used_location],
        emoney_account_transaction_param[:share],
        emoney_account_transaction_param[:group_id],
    )
    render json: {}, status: 200 and return if @response.blank?

    render 'update', formats: 'json', handlers: 'jbuilder'
  end

  def get_emoney_account_transaction_param(params, transaction_id, exist_transaction)
    at_transaction_category_id = params[:at_transaction_category_id].present? ?
                                     params[:at_transaction_category_id] : exist_transaction[:at_transaction_category_id]
    used_location = params[:used_location].present? ? params[:used_location] : exist_transaction[:used_location]
    share = params[:share].present? ? params[:share] : false
    {
        emoney_account_id: params[:emoney_account_id],
        transaction_id: transaction_id,
        at_transaction_category_id: at_transaction_category_id,
        used_location: used_location,
        share: share,
        group_id: share ? @current_user.group_id : nil
    }
  end


end
