class Api::V2::User::CardTransactionsController < ApplicationController
  before_action :authenticate

  def index
    account_id = params[:card_account_id].to_i
    if disallowed_at_card_ids?([account_id])
      render_disallowed_financier_ids && return
    end

    @transactions = Services::AtCardTransactionService.new(
        @current_user,
        false,
        params[:from],
        params[:to]
    ).list(account_id)

    render json: {}, status: 200 and return if @transactions.blank?
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
end
