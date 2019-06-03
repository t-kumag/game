# TODO(fujiura) group で取得する明細の情報を明確にする
class Api::V1::Group::EmoneyTransactionsController < ApplicationController
  before_action :authenticate
  
  def index
    @transactions = Services::AtEmoneyTransactionService.new.list(params[:emoney_account_id])
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def show
    @response = Services::AtEmoneyTransactionService.new.detail(params[:emoney_account_id], params[:id])
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def update
    @response = Services::AtEmoneyTransactionService.new.update(params[:id], params[:at_transaction_category_id], params[:used_location], params[:is_shared])

    # TODO(fujiura): 何を返すべき？
    render 'update', formats: 'json', handlers: 'jbuilder'
  end

end
