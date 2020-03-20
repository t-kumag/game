class Api::V1::Group::TransactionsController < ApplicationController
  before_action :authenticate

  def index
    @response = []

    if disallowed_transaction_ids_date?(params[:from])
      render_disallowed_transaction_ids_date && return
    end

    # 同じグループに種属するユーザの明細を自ユーザ含めてユーザごとに取得しマージする
    @response += Services::TransactionService.new(
        @current_user,
        params[:category_id],
        true,                # share 
        params[:scope],
        true,                # with_group
        params[:from],
        params[:to]
    ).list

    @response += Services::TransactionService.new(
        @current_user.partner_user,
        params[:category_id],
        true,                # share 
        params[:scope],
        true,                # with_group
        params[:from],
        params[:to]
    ).list if @current_user.partner_user.present?

    if params.has_key?(:distributed_type)
      tr_service = Services::TransactionService.new(
          @current_user,
          nil,                 # category_id
          true,                # share
          nil,                 # scope
          true,                # with_group
          nil,                 # from
          nil                  # to
      )
      @response = tr_service.fetch_tran_type(@response, set_response)
    end

    # TODO: マージした明細の時系列での並べ替え
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def grouped_transactions
    @response = []

    # 同じグループに種属するユーザの明細を自ユーザ含めてユーザごとに取得しマージする
    @response += Services::TransactionService.new(
        @current_user,
        params[:category_id],
        true,                # share
        params[:scope],
        true,                # with_group
        params[:from],
        params[:to]
    ).grouped

    @response += Services::TransactionService.new(
        @current_user.partner_user,
        params[:category_id],
        true,                # share
        params[:scope],
        true,                # with_group
        params[:from],
        params[:to]
    ).grouped if @current_user.partner_user.present?

    # TODO: マージした明細の時系列での並べ替え
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  private
  def set_response
    response = {}
    response[:family] = []
    response[:owner] = []
    response[:partner] = []
    response
  end
end
