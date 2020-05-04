class Api::V1::Group::TransactionsController < ApplicationController
  before_action :authenticate

  def index

    # プレミアム機能を一時コメントアウト
    # 4月中旬頃にアプリの課金対応の改修後に再度反映予定
    #if disallowed_transactions_date?(params[:from])
    #  render_disallowed_transactions_date && return
    #end

    # 同じグループに種属するユーザの明細を自ユーザ含めてユーザごとに取得しマージする
    @response = Services::TransactionService.new(
        @current_user,
        @category_version,
        params[:category_id],
        true,                # share
        params[:scope],
        true,                # with_group
        params[:from],
        params[:to]
    ).list

    if params.has_key?(:distributed_type)
      @response = Services::TransactionService.fetch_tran_type(@response, params[:distributed_type], @current_user)
    end

    @category_map = Services::CategoryService.new(@category_version).category_map
    # TODO: マージした明細の時系列での並べ替え
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def grouped_transactions

    # 同じグループに種属するユーザの明細を自ユーザ含めてユーザごとに取得しマージする
    @response = Services::TransactionService.new(
        @current_user,
        @category_version,
        params[:category_id],
        true,                # share
        params[:scope],
        true,                # with_group
        params[:from],
        params[:to]
    ).grouped

    @category_map = Services::CategoryService.new(@category_version).category_map
    # TODO: マージした明細の時系列での並べ替え
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

end
