class Api::V1::User::EmoneyTransactionsController < ApplicationController
  before_action :authenticate
  # TODO(fujiura): before_action で対象口座へのアクセス権があるかチェックする
  # TODO(fujiura): emoney_account_id, transaction_id に対応するデータがないときの処理

  def index
    @transactions = Services::AtEmoneyTransactionService.new.list(params[:emoney_account_id], params[:page])
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def show
    @response = Services::AtEmoneyTransactionService.new.detail(params[:emoney_account_id], params[:id])
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def update
    @response = Services::AtEmoneyTransactionService.new.update(
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
