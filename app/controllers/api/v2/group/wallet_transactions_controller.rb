class Api::V2::Group::WalletTransactionsController < ApplicationController
  before_action :authenticate

  def index
    wallet_id = params[:wallet_id].to_i
    if disallowed_wallet_ids?([wallet_id], true)
      render_disallowed_financier_ids && return
    end

    @transactions = Services::WalletTransactionService.new(
        @current_user,
        true,
        params[:from],
        params[:to]
    ).list(wallet_id)

    render(json: {}, status: 200) && return if @transactions.blank?
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def show
    transaction_id = params[:id].to_i
    @response = Services::WalletTransactionService.new(@current_user, true).detail(params[:wallet_id], transaction_id)
    render(json: {}, status: 200) && return if @response.blank?
    render 'show', formats: 'json', handlers: 'jbuilder'
  end
end
