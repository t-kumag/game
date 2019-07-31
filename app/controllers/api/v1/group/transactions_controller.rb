class Api::V1::Group::TransactionsController < ApplicationController
  before_action :authenticate, :require_group

  def index
    @response = []
   
    # 同じグループに種属するユーザの明細を自ユーザ含めてユーザごとに取得しマージする
    @response += Services::TransactionService.new(@current_user, params[:from], params[:to], params[:category_id], false, true).list
    @response += Services::TransactionService.new(@current_user.partner_user, params[:from], params[:to], params[:category_id], false, true).list

    # TODO: マージした明細の時系列での並べ替え
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def grouped_transactions
    @response = []

    # 同じグループに種属するユーザの明細を自ユーザ含めてユーザごとに取得しマージする
    @response += Services::TransactionService.new(@current_user, params[:from], params[:to], params[:category_id], false, true).grouped
    @response += Services::TransactionService.new(@current_user.partner_user, params[:from], params[:to], params[:category_id], false, true).grouped

    # TODO: マージした明細の時系列での並べ替え
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
end
