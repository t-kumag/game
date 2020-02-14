class Api::V1::User::BankTransactionsController < ApplicationController
  before_action :authenticate

  def index
    account_id = params[:bank_account_id].to_i
    if disallowed_at_bank_ids?([account_id])
      render_disallowed_financier_ids && return
    end

    @transactions = Services::AtBankTransactionService.new(
        @current_user,
        false,
        params[:from],
        params[:to]
    ).list(account_id)

    render json: {}, status: 200 and return if @transactions.blank?
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def show
    transaction_id = params[:id].to_i
    if disallowed_at_bank_transaction_ids?(params[:bank_account_id], [transaction_id])
      render_disallowed_transaction_ids && return
    end

    @response = Services::AtBankTransactionService.new(@current_user).detail(params[:bank_account_id], transaction_id)
    render json: {}, status: 200 and return if @response.blank?
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def update
    transaction_id = params[:id].to_i
    if disallowed_at_bank_transaction_ids?(params[:bank_account_id], [transaction_id])
      render_disallowed_transaction_ids && return
    end

    @exist_bank_transaction = Services::AtBankTransactionService.new(@current_user).detail(params[:bank_account_id], transaction_id)
    bank_account_transaction_param = get_bank_account_transaction_param(params, transaction_id, @exist_bank_transaction)

    @response = Services::AtBankTransactionService.new(@current_user).update(
        bank_account_transaction_param[:bank_account_id],
        bank_account_transaction_param[:transaction_id],
        bank_account_transaction_param[:at_transaction_category_id],
        bank_account_transaction_param[:used_location],
        bank_account_transaction_param[:memo],
        bank_account_transaction_param[:share],
        bank_account_transaction_param[:ignore],
        bank_account_transaction_param[:group_id],
    )

    if @response[:user_distributed_transaction].share
      options = create_activity_options(@response[:user_distributed_transaction], bank_account_transaction_param, "family")
      Services::ActivityService.create_activity(@current_user.id, @response[:user_distributed_transaction].group_id,
                                                DateTime.now, :person_tran_to_family, options)
      Services::ActivityService.create_activity(@current_user.partner_user.try(:id), @response[:user_distributed_transaction].group_id,
                                                DateTime.now, :person_tran_to_family_partner, options)
    end

    render json: {}, status: 200 and return if @response[:user_distributed_transaction].blank?
    render 'update', formats: 'json', handlers: 'jbuilder'
  end

  def get_bank_account_transaction_param(params, transaction_id, exist_transaction)
    at_transaction_category_id = params[:at_transaction_category_id].present? ?
                                     params[:at_transaction_category_id] : exist_transaction[:at_transaction_category_id]
    used_location = params[:used_location].present? ? params[:used_location] : exist_transaction[:used_location]
    memo = params[:memo].present? ? params[:memo] : exist_transaction[:memo]
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

  private
  def create_activity_options(transaction, bank_account_transaction_param, account)
    options = {}
    options[:goal] = nil
    options[:transaction] = create_transaction(transaction, bank_account_transaction_param, account)
    options[:transactions] = nil
    options
  end

  def create_transaction(transaction, bank_account_transaction_param, account)
    tran = {}
    tran[:id] = transaction.at_user_bank_transaction_id
    tran[:account_id] = bank_account_transaction_param[:bank_account_id]
    tran[:account] = account
    tran[:type] = "bank"
    tran
  end
end
