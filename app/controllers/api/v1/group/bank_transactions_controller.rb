# TODO(fujiura) group で取得する明細の情報を明確にする
class Api::V1::Group::BankTransactionsController < ApplicationController
  before_action :authenticate
  
  def index
    account_id = params[:bank_account_id].to_i
    if disallowed_at_bank_ids?([account_id], true)
      render_disallowed_financier_ids && return
    end
    
    @transactions = Services::AtBankTransactionService.new(@current_user, true).list(account_id, params[:page])
    render json: {}, status: 200 and return if @transactions.blank?
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def show
    transaction_id = params[:id].to_i
    if disallowed_at_bank_transaction_ids?(params[:bank_account_id], [transaction_id], true)
      render_disallowed_transaction_ids && return
    end

    @response = Services::AtBankTransactionService.new(@current_user, true).detail(params[:bank_account_id], transaction_id)
    render json: {}, status: 200 and return if @response.blank?
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def update
    @response = Services::AtBankTransactionService.new(@current_user, true).update(
        params[:bank_account_id],
        params[:id],
        params[:at_transaction_category_id],
        params[:used_location],
        params[:is_shared],
        params[:is_shared] ? @current_user.group_id : nil
    )
    render json: {}, status: 200 and return if @response.blank?

    # TODO(fujiura): 何を返すべき？
    render 'update', formats: 'json', handlers: 'jbuilder'
  end

end
