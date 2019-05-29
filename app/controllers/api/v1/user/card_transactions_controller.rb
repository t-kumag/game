class Api::V1::User::CardTransactionsController < ApplicationController
  before_action :authenticate
  # TODO(fujiura): before_action で対象口座へのアクセス権があるかチェックする
  # TODO(fujiura): card_account_id, transaction_id に対応するデータがないときの処理

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
