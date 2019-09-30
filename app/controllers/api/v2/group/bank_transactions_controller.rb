class Api::V2::Group::BankTransactionsController < ApplicationController
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

    render json: {}, status: 200 and return if @transactions.blank?
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
end
