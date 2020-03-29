class Api::V2::User::EmoneyTransactionsController < ApplicationController
  before_action :authenticate

  def index
    account_id = params[:emoney_account_id].to_i
    render_disallowed_financier_ids && return if disallowed_at_emoney_ids?([account_id])

    @transactions = Services::AtEmoneyTransactionService.new(
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
