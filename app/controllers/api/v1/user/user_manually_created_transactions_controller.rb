class Api::V1::User::UserManuallyCreatedTransactionsController < ApplicationController
  before_action :authenticate

  @error = {}

  def show
    @response = find_transaction
    render_disallowed_transaction_ids && return if @response.blank?
    render :show, formats: :json, handlers: :jbuilder
  end

  def create
    begin
      Entities::UserManuallyCreatedTransaction.new.transaction do
        transaction = create_user_manually_created
        if params[:share] === true
          require_group && return
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
        transaction = find_transaction
        render_disallowed_transaction_ids && return if transaction.blank?
        update_user_manually_created(transaction)

        if params[:share] === true
          require_group && return
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
    render_disallowed_transaction_ids && return if transaction.blank?

    begin
      Entities::UserManuallyCreatedTransaction.new.transaction do
        transaction.destroy!
      end
    rescue => exception
      raise exception
    end
    render(json: {}, status: 200)
  end

  private

  def find_transaction
    # パラメータの明細IDが自身の明細の場合、明細のシェア関係なく返す
    transacticon = Entities::UserManuallyCreatedTransaction.try(:find_by,  id: params[:id], user_id: @current_user.id)
    if transacticon.blank? && @current_user.group_id.present?
      # パラメータの明細IDがパートナーの明細の場合、シェアされている明細を返す
      transacticon = Entities::UserManuallyCreatedTransaction.try(:find_by, id: params[:id], user_id: @current_user.try(:partner_user).try(:id))
      # シェアしていない明細は、422を返す
      transacticon = nil unless transacticon.try(:user_distributed_transaction).try(:share)
    end
    
    transacticon
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

    Services::ActivityService.create_user_manually_activity(@current_user.id,
                                                            @current_user.group_id,
                                                            save_params[:used_date],
                                                            'individual_manual_outcome')
    Entities::UserManuallyCreatedTransaction.create!(save_params)

  end

  def update_user_manually_created(transaction)
    save_params = params.permit(
      :at_transaction_category_id,
      :payment_method_id,
      :used_date,
      :title,
      :amount,
      :used_location
    )

    transaction.update!(update_param(save_params, transaction))
    Services::ActivityService.create_user_manually_activity(@current_user.id,
                                                            @current_user.group_id,
                                                            transaction[:used_date],
                                                            'individual_manual_outcome')
    transaction
  end

  def update_param(save_param, transaction)

    at_transaction_category_id = save_param[:at_transaction_category_id].present? ?
                                     save_param[:at_transaction_category_id] : transaction[:at_transaction_category_id]
    payment_method_id = save_param[:payment_method_id].present? ? save_param[:payment_method_id] : transaction[:payment_method_id]
    used_date = save_param[:used_date].present? ? save_param[:used_date] : transaction[:used_date]
    title = save_param[:title].present? ? save_param[:title] : transaction[:title]
    amount = save_param[:amount].present? ? save_param[:amount] : transaction[:amount]
    used_location = save_param[:used_location].present? ? save_param[:used_location] : transaction[:used_location]

    {
        at_transaction_category_id: at_transaction_category_id,
        payment_method_id: payment_method_id,
        used_date: used_date,
        title: title,
        amount: amount,
        used_location: used_location
    }
  end
end
