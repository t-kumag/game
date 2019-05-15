class Api::V1::User::UserManuallyCreatedTransactionsController < ApplicationController
  before_action :authenticate

  @error = {}

  def show
    @response = find_transaction
    render(json: {}, status: 404) if @response.blank?
    render :show, formats: :json, handlers: :jbuilder
  end

  def create
    begin
      Entities::UserManuallyCreatedTransaction.new.transaction do
        transaction = create_user_manually_created
        Services::UserManuallyCreatedTransactionService.new(@current_user, transaction).create_user_manually_created
      end

    rescue => exception
      logger.error exception
      render(json: {}, status: 400) && return
    end

    render(json: {}, status: 200)
  end

  def update
    begin
      Entities::UserManuallyCreatedTransaction.new.transaction do
        transaction = update_user_manually_created
        Services::UserManuallyCreatedTransactionService.new(@current_user, transaction).update_user_manually_created
      end

    rescue => exception
      logger.error exception
      render(json: {}, status: 400) && return
    end

    render(json: {}, status: 200)
  end

  def destroy
    transaction = find_transaction
    render(json: {}, status: 404) if transaction.blank?
    begin
      Entities::UserManuallyCreatedTransaction.new.transaction do
        transaction.destroy
      end

    rescue => exception
      logger.error exception
      render(json: {}, status: 400) && return
    end
    render(json: {}, status: 200)
  end

  private

  def find_transaction
    Entities::UserManuallyCreatedTransaction.where(id: params[:id]).first
  end

  def create_user_manually_created
    save_params = params.permit(
      :group_id,
      :share,
      :at_transaction_category_id,
      :payment_method_id,
      :used_date,
      :title,
      :amount,
      :used_location
    ).merge(
      user_id: @current_user.id
    )
    Entities::UserManuallyCreatedTransaction.create!(save_params)
  end

  def update_user_manually_created
    save_params = params.permit(
      :id,
      :group_id,
      :share,
      :at_transaction_category_id,
      :payment_method_id,
      :used_date,
      :title,
      :amount,
      :used_location
    ).merge(
      user_id: @current_user.id
    )
    Entities::UserManuallyCreatedTransaction.find(params[:id]).update!(save_params)
    Entities::UserManuallyCreatedTransaction.find(params[:id])
  end
end
