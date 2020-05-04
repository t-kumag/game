class Api::V2::Group::TransactionsController < ApplicationController
  before_action :authenticate

  def summary_transactions

    # プレミアム機能を一時コメントアウト
    # 4月中旬頃にアプリの課金対応の改修後に再度反映予定
    #if disallowed_transactions_date?(params[:from])
    #  render_disallowed_transactions_date && return
    #end

    transactions = []

    # 同じグループに種属するユーザの明細を自ユーザ含めてユーザごとに取得しマージする
    transactions = Services::TransactionService.new(
        @current_user,
        @category_version,
        nil,                 # category_id
        true,                # share
        params[:scope],      # scope
        true,                # with_group
        params[:from],
        params[:to]
    ).list

    transaction = Services::TransactionService.fetch_summary_distributed_type(transactions, @current_user)
    @response = Services::TransactionService.fetch_detail(transaction, transactions.sum{|i| i[:amount]})

    # TODO: マージした明細の時系列での並べ替え
    render 'summary_list', formats: 'json', handlers: 'jbuilder'

  end

end
