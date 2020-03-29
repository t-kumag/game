class Api::V1::User::TransactionsController < ApplicationController
  before_action :authenticate

  def index
    @response = Services::TransactionService.new(
        @current_user,
        @category_version,
        params[:category_id],
        params[:share],
        params[:scope],
        false,
        params[:from],
        params[:to]
    ).list
    @category_map = Services::CategoryService.new(@category_version).category_map
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def grouped_transactions
    @response = Services::TransactionService.new(
        @current_user,
        @category_version,
        params[:category_id],
        params[:share],
        params[:scope],
        false,
        params[:from],
        params[:to]
    ).grouped
    @category_map = Services::CategoryService.new(@category_version).category_map
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
end
