class Api::V1::Group::TransactionsController < ApplicationController
  before_action :authenticate

  def index
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

  def expense_transactions
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

    transaction = tr_service.fetch_expense_all(transactions, @response)

    @response[:family] = tr_service.fetch_expense(transaction[:family], transactions.count)
    @response[:owner] = tr_service.fetch_expense(transaction[:owner], transactions.count)
    @response[:partner] = tr_service.fetch_expense(transaction[:partner], transactions.count)

    # TODO: マージした明細の時系列での並べ替え
    render 'expense_list', formats: 'json', handlers: 'jbuilder'

  end

  private
  def set_response
    response = {}
    response[:family] = {}
    response[:owner] = {}
    response[:partner] = {}
    response
  end
end
