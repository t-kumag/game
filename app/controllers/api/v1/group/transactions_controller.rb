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
    @response = {}
    @response[:owner] = {}
    @response[:partner] = {}
    @response[:family] = {}

    # 同じグループに種属するユーザの明細を自ユーザ含めてユーザごとに取得しマージする
    user_transaction = Services::TransactionService.new(
        @current_user,
        nil,                 # category_id
        true,                # share
        nil,                 # scope
        true,                # with_group
        params[:from],
        params[:to]
    ).grouped


    partner_transaction = Services::TransactionService.new(
        @current_user.partner_user,
        nil,                 # category_id
        true,                # share
        nil,                 # scope
        true,                # with_group
        params[:from],
        params[:to]
    ).grouped if @current_user.partner_user.present?

    family = []
    family += user_transaction
    family += partner_transaction

    @response[:owner] = Services::TransactionService.expense_list(user_transaction, family.count)
    @response[:partner] = Services::TransactionService.expense_list(partner_transaction, family.count)
    binding.pry

    # TODO: マージした明細の時系列での並べ替え
    render 'expense_list', formats: 'json', handlers: 'jbuilder'

  end
end
