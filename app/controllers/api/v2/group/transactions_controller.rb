class Api::V2::Group::TransactionsController < ApplicationController
  before_action :authenticate

  def summary_transactions
    @response = set_response
    transactions = []

    # 同じグループに種属するユーザの明細を自ユーザ含めてユーザごとに取得しマージする
    transactions += Services::TransactionService.new(
        @current_user,
        nil,                 # category_id
        true,                # share
        nil,                 # scope
        true,                # with_group
        params[:from],
        params[:to]
    ).list


    transactions += Services::TransactionService.new(
        @current_user.partner_user,
        nil,                 # category_id
        true,                # share
        nil,                 # scope
        true,                # with_group
        params[:from],
        params[:to]
    ).list if @current_user.partner_user.present?

    tr_service = Services::TransactionService.new(
        @current_user,
        nil,                 # category_id
        true,                # share
        nil,                 # scope
        true,                # with_group
        nil,                 # from
        nil                  # to
    )

    transaction = tr_service.fetch_summary_all_type(transactions, @response)

    @response[:family] = tr_service.fetch_expense(transaction[:family], transactions.count)
    @response[:owner] = tr_service.fetch_expense(transaction[:owner], transactions.count)
    @response[:partner] = tr_service.fetch_expense(transaction[:partner], transactions.count)
    @response[:pair_diff_total] = tr_service.fetch_pair_diff_total_amount(@response)
    @response[:pair_total_amount] = tr_service.fetch_pair_total_amount(@response)

    # TODO: マージした明細の時系列での並べ替え
    render 'summary_list', formats: 'json', handlers: 'jbuilder'

  end

  private
  def set_response
    response = {}
    response[:family] = []
    response[:owner] = []
    response[:partner] = []
    response[:diff_total] = nil
    response
  end

end
