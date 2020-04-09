class Api::V1::Group::BankTransactionsController < ApplicationController
  before_action :authenticate

  def index
    account_id = params[:bank_account_id].to_i
    if disallowed_at_bank_ids?([account_id], true)
      render_disallowed_financier_ids && return
    end

    @transactions = Services::AtBankTransactionService.new(
        @current_user,
        true,
        params[:from],
        params[:to]
    ).list(account_id)
    @category_map = Services::CategoryService.new(@category_version).category_map

    render json: {}, status: 200 and return if @transactions.blank?
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def show
    transaction_id = params[:id].to_i
    if disallowed_at_bank_transaction_ids?(params[:bank_account_id], [transaction_id], true)
      render_disallowed_transaction_ids && return
    end

    @response = Services::AtBankTransactionService.new(@current_user, true).detail(params[:bank_account_id], transaction_id)
    @category_map = Services::CategoryService.new(@category_version).category_map

    render json: {}, status: 200 and return if @response.blank?
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def update
    transaction_id = params[:id].to_i
    if disallowed_at_bank_transaction_ids?(params[:bank_account_id], [transaction_id], true)
      render_disallowed_transaction_ids && return
    end

    @exist_transaction = Services::AtBankTransactionService.new(@current_user, true).detail(params[:bank_account_id], transaction_id)
    render_disallowed_transaction_ids && return unless @exist_transaction.present?
    bank_account_transaction_param = get_bank_account_transaction_param(params, transaction_id, @exist_transaction)
    at_transaction_category_id = Services::CategoryService.new(@category_version).convert_at_transaction_category_id(params[:at_transaction_category_id])

    @response = Services::AtBankTransactionService.new(@current_user, true).update(
        bank_account_transaction_param[:bank_account_id],
        bank_account_transaction_param[:transaction_id],
        bank_account_transaction_param[:at_transaction_category_id],
        bank_account_transaction_param[:used_location],
        bank_account_transaction_param[:memo],
        bank_account_transaction_param[:share],
        bank_account_transaction_param[:ignore],
        bank_account_transaction_param[:group_id],
    )
    render json: {}, status: 200 and return if @response.blank?

    render 'update', formats: 'json', handlers: 'jbuilder'
  end


  private
  def get_bank_account_transaction_param(params, transaction_id, exist_transaction)
    at_transaction_category_id = params[:at_transaction_category_id].present? ?
                                     params[:at_transaction_category_id] : exist_transaction[:at_transaction_category_id]
    at_transaction_category_id = Services::CategoryService.new(@category_version).convert_at_transaction_category_id(at_transaction_category_id)

    used_location = params[:used_location].nil? ? exist_transaction[:used_location] : params[:used_location]
    memo = params[:memo].blank? ? nil : params[:memo]
    share = params[:share].present? ? params[:share] : false
    ignore = params[:ignore].present? ? params[:ignore] : false

    {
        bank_account_id: params[:bank_account_id],
        transaction_id: transaction_id,
        at_transaction_category_id: at_transaction_category_id,
        used_location: used_location,
        memo: memo,
        share: share,
        ignore: ignore,
        group_id: share ? @current_user.group_id : nil
    }
  end

end
