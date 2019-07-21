# TODO(fujiura) group で取得する明細の情報を明確にする
class Api::V1::Group::EmoneyTransactionsController < ApplicationController
  before_action :authenticate
  before_action :require_group, only: [:update]

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
