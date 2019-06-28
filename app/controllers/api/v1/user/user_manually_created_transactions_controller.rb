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
      :at_transaction_category_id,
      :payment_method_id,
      :used_date,
      :title,
      :amount,
      :used_location
    ).merge(
      user_id: @current_user.id
    )

    p @current_user
    Services::ActivityService.new.create_user_manually_activity(@current_user, save_params, :individual_manual_outcome)
    Entities::UserManuallyCreatedTransaction.create!(save_params)

  end

  def update_user_manually_created
    save_params = params.require(:user_manually_created_transaction).permit(
      :id,
      :at_transaction_category_id,
      :payment_method_id,
      :used_date,
      :title,
      :amount,
      :used_location
    ).merge(
      user_id: @current_user.id
    )

    Services::ActivityService.new.create_user_manually_activity(@current_user, save_params, :individual_manual_outcome)
    Entities::UserManuallyCreatedTransaction.find(save_params[:id]).update!(save_params)
    Entities::UserManuallyCreatedTransaction.find(save_params[:id])
  end
end
