class Api::V1::Group::TransactionsController < ApplicationController
  before_action :authenticate, :require_group

  def index
    @response = []
   
    # 同じグループに種属するユーザの明細を自ユーザ含めてユーザごとに取得しマージする
    @response += Services::TransactionService.new(
        @current_user,
        params[:category_id],
        false,
        params[:scope],
        true,
        params[:from],
        params[:to]
    ).list

    @response += Services::TransactionService.new(
        @current_user.partner_user,
        params[:category_id],
        false,
        params[:scope],
        true,
        params[:from],
        params[:to]
    ).list

    # TODO: マージした明細の時系列での並べ替え
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def grouped_transactions
    @response = []

    # 同じグループに種属するユーザの明細を自ユーザ含めてユーザごとに取得しマージする
    @response += Services::TransactionService.new(
        @current_user,
        params[:category_id],
        false,
        params[:scope],
        false,
        params[:from],
        params[:to]
    ).grouped

    @response += Services::TransactionService.new(
        @current_user.partner_user,
        params[:category_id],
        false,
        params[:scope],
        true,
        params[:from],
        params[:to]
    ).grouped

    # TODO: マージした明細の時系列での並べ替え
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
end
