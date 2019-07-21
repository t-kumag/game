class Api::V1::User::UserManuallyCreatedTransactionsController < ApplicationController
  before_action :authenticate
  before_action :require_group, only: [:create, :update]

  @error = {}

  def show
    @response = find_transaction
    render(json: { errors: { code: '', mesasge: "record not found." } }, status: 422) and return if @response.blank?
    render :show, formats: :json, handlers: :jbuilder
  end

  def create
    begin
      Entities::UserManuallyCreatedTransaction.new.transaction do
        transaction = create_user_manually_created
        if params[:share] === true
          options = {group_id: @current_user.group_id, share: params[:share]}
        else
          options = {}
        end
        Services::UserManuallyCreatedTransactionService.new(@current_user, transaction).create_user_manually_created(options)
      end

    rescue => exception
      raise exception
    end

    render(json: {}, status: 200)
  end

  def update
    begin
      Entities::UserManuallyCreatedTransaction.new.transaction do
        transaction = update_user_manually_created
        if params[:share] === true
          options = {group_id: @current_user.group_id, share: params[:share]}
        else
          options = {}
        end
        Services::UserManuallyCreatedTransactionService.new(@current_user, transaction).update_user_manually_created(options)
      end

    rescue => exception
      raise exception
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
      raise exception
    end
    render(json: {}, status: 200)
  end

  private

  def find_transaction
    Entities::UserManuallyCreatedTransaction.find_by(id: params[:id], user_id: @current_user.id)
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

    Services::ActivityService.create_user_manually_activity(@current_user, save_params, :individual_manual_outcome)
    Entities::UserManuallyCreatedTransaction.create!(save_params)

  end

  def update_user_manually_created
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

    Services::ActivityService.create_user_manually_activity(@current_user, save_params, :individual_manual_outcome)
    Entities::UserManuallyCreatedTransaction.find(params[:id]).update!(save_params)
    Entities::UserManuallyCreatedTransaction.find(params[:id])
  end
end
