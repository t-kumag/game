# TODO(fujiura) group で取得する明細の情報を明確にする
class Api::V1::Group::CardTransactionsController < ApplicationController
  before_action :authenticate
    
  def index
    @transactions = Services::AtCardTransactionService.new.list(params[:card_account_id])
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def show
    @response = Services::AtCardTransactionService.new.detail(params[:id], params[:card_account_id])
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def update
    @response = Services::AtCardTransactionService.new.update(params[:id], params[:at_transaction_category_id], params[:used_location], params[:is_shared])
    # TODO(fujiura): 何を返すべき？
    render 'update', formats: 'json', handlers: 'jbuilder'
  end

end
