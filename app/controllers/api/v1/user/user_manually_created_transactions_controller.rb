class Api::V1::User::UserManuallyCreatedTransactionsController < ApplicationController
  before_action :authenticate

  @error = {}

  def index
    @transactions = Entities::UserManuallyCreatedTransaction.where(user_id: @current_user.id)
    render :index, formats: :json, handlers: :jbuilder
  end

  def show
    @response = find_transaction
    render_disallowed_transaction_ids && return if @response.blank?
    render :show, formats: :json, handlers: :jbuilder
  end

  def create
    begin
      Entities::UserManuallyCreatedTransaction.new.transaction do
        user_manually_created_transaction = create_user_manually_created
        if params[:share] === true
          require_group && return
          options = {group_id: @current_user.group_id, share: params[:share], transaction: nil}
        else
          options = {transaction: nil}
        end
        transaction = Services::UserManuallyCreatedTransactionService.new(@current_user, user_manually_created_transaction).create_user_manually_created(options)
        options[:user_manually_created_transaction] = create_transaction(transaction)
        create_user_manually_activity(@current_user, transaction[:used_date], options)
      end

    rescue => exception
      raise exception
    end

    render(json: {}, status: 200)
  end

  def update

    begin
      Entities::UserManuallyCreatedTransaction.new.transaction do
        user_manually_created_transaction = find_transaction
        render_disallowed_transaction_ids && return if user_manually_created_transaction.blank?
        update_user_manually_created(user_manually_created_transaction)

        if params[:share] === true
          require_group && return
          options = {group_id: @current_user.group_id, share: params[:share]}
        else
          options = {}
        end
        Services::UserManuallyCreatedTransactionService.new(@current_user, user_manually_created_transaction).update_user_manually_created(options)
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
    transacticon = Entities::UserManuallyCreatedTransaction.find_by(id: params[:id], user_id: @current_user.id)
    if transacticon.blank? && @current_user.group_id.present?
      # パラメータの明細IDがパートナーの明細の場合、シェアされている明細を返す
      transacticon = Entities::UserManuallyCreatedTransaction.find_by(id: params[:id], user_id: @current_user.partner_user.id)
      # シェアしていない明細は、422を返す
      transacticon = nil unless transacticon.try(:user_distributed_transaction).try(:share)
    end
    
    transacticon
  end

  def create_user_manually_created
    convert_amount params
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

    Entities::UserManuallyCreatedTransaction.create!(save_params)

  end

  def update_user_manually_created(transaction)
    convert_amount params
    save_params = params.permit(
      :at_transaction_category_id,
      :payment_method_id,
      :used_date,
      :title,
      :amount,
      :used_location
    )

    transaction.update!(update_param(save_params, transaction))
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

  # params[:type]の指定でamountの符号を変換する
  def convert_amount(params)
    params[:amount] ||= 0
    params[:amount] = payment_amount unless params.has_key?(:type)
    params[:amount] = payment_amount if params[:type] == 'payment'
    params[:amount] = receipt_amount if params[:type] == 'receipt'
  end

  # 支出金額 マイナス変換する
  def payment_amount
    return  params[:amount] if params[:amount] < 0
    return -params[:amount] if params[:amount] > 0
    0
  end

  # 入金金額 プラス変換する
  def receipt_amount
    return  params[:amount] if params[:amount] > 0
    return -params[:amount] if params[:amount] < 0
    0
  end


  def create_user_manually_activity(current_user, used_date, options)
    if options[:user_manually_created_transaction][:share]
      # 無駄なキーを渡すと誤作動を起こす可能性があるので削除します。
      options.delete(:group_id)
      options.delete(:share)
      Services::ActivityService.create_activity(current_user.id, current_user.group_id, used_date, :individual_manual_outcome, options)
      Services::ActivityService.create_activity(current_user.partner_user.id, current_user.group_id, used_date, :individual_manual_outcome_fam, options)
    else
      Services::ActivityService.create_activity(current_user.id, current_user.group_id, used_date, :individual_manual_outcome, options)
    end
  end

  def create_transaction(transaction)
    tran = {}
    tran[:id] = transaction.user_manually_created_transaction_id
    tran[:share] = transaction.share
    tran[:type] = "manually_created"
    tran
  end

end
