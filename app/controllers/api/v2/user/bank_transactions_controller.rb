class Api::V2::User::BankTransactionsController < ApplicationController
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
    @category_map = Services::CategoryService.new(@category_version).category_map

    render json: {}, status: 200 and return if @transactions.blank?
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
end
