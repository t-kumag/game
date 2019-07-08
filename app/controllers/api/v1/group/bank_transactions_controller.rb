# TODO(fujiura) group で取得する明細の情報を明確にする
class Api::V1::Group::BankTransactionsController < ApplicationController
  before_action :authenticate

  def index
    @transactions = Services::AtBankTransactionService.new.list(params[:bank_account_id], params[:page])
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def show
    @response = Services::AtBankTransactionService.new.detail(params[:bank_account_id], params[:id])
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def update
    @response = Services::AtBankTransactionService.new.update(
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
