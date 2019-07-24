# TODO(fujiura) group で取得する明細の情報を明確にする
class Api::V1::Group::CardTransactionsController < ApplicationController
  before_action :authenticate

  def index
    @transactions = Services::AtCardTransactionService.new(@current_user, true).list(params[:card_account_id], params[:page])
    render json: {}, status: 200 and return if @transactions.blank?
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def show
    @response = Services::AtCardTransactionService.new(@current_user, true).detail(params[:card_account_id], params[:id])
    render json: {}, status: 200 and return if @response.blank?
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def update
    @response = Services::AtCardTransactionService.new(@current_user, true).update(
        params[:card_account_id],
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
