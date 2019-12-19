class Api::V2::User::WalletTransactionsController < ApplicationController
  before_action :authenticate

  def index
    wallet_id = params[:wallet_id].to_i
    # if disallowed_at_bank_ids?([wallet_id])
    #   render_disallowed_financier_ids && return
    # end

    @transactions = Services::WalletTransactionService.new(
      @current_user,
      false,
      params[:from],
      params[:to]
    ).list(wallet_id)

    render(json: {}, status: 200) && return if @transactions.blank?
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def show
    transaction_id = params[:id].to_i
    # if disallowed_at_bank_transaction_ids?(params[:bank_account_id], [transaction_id])
    #   render_disallowed_transaction_ids && return
    # end

    @response = Services::WalletTransactionService.new(@current_user).detail(params[:wallet_id], transaction_id)
    render(json: {}, status: 200) && return if @response.blank?
    render 'show', formats: 'json', handlers: 'jbuilder'
  end
end
