class Api::V1::User::CardTransactionsController < ApplicationController
  before_action :authenticate
  # TODO(fujiura): before_action で対象口座へのアクセス権があるかチェックする
  # TODO(fujiura): card_account_id, transaction_id に対応するデータがないときの処理

  def index
    @transactions = Services::AtCardTransactionService.new(@current_user).list(params[:card_account_id], params[:page])
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def show
    @response = Services::AtCardTransactionService.new(@current_user).detail(params[:card_account_id], params[:id],)
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def update
    @response = Services::AtCardTransactionService.new(@current_user).update(
        params[:id],
        params[:at_transaction_category_id],
        params[:used_location],
        params[:is_shared],
        params[:is_shared] ? @current_user.group_id : nil
    )
    # TODO(fujiura): 何を返すべき？
    render 'update', formats: 'json', handlers: 'jbuilder'
  end

end
