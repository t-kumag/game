class Api::V2::User::StockAccountsController < ApplicationController
  before_action :authenticate

  def index
    @responses = []
    if @current_user.try(:at_user).present? && @current_user.try(:at_user).try(:at_user_stock_accounts).present?
      @current_user.at_user.at_user_stock_accounts.where(share: false).each do |a|
      @responses << {
          id: a.id,
          name: a.name.present? ? a.name : a.fnc_nm,
          balance: a.balance,
          deposit_balance: a.deposit_balance,
          profit_loss_amount: a.profit_loss_amount,
          fnc_id: a.fnc_id,
          last_rslt_cd: a.last_rslt_cd,
          last_rslt_msg: a.last_rslt_msg
      }
      end
    end
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def update
    account_id = params[:id].to_i
    if disallowed_at_stock_ids?([account_id])
      render_disallowed_financier_ids && return
    end

    if @current_user.try(:at_user).try(:at_user_stock_accounts).pluck(:id).include?(account_id)
      account = Entities::AtUserStockAccount.find account_id
      account.update!(get_account_params)
      if account.share?
        options = create_activity_options('family')
        Services::ActivityService.create_activity(@current_user.id, @current_user.group_id,  DateTime.now, :person_account_to_family, options)
        Services::ActivityService.create_activity(@current_user.partner_user.try(:id), @current_user.group_id,  DateTime.now, :person_account_to_family_partner, options)
      end
      render json: {}, status: 204
    else
      render json: { errors: [ERROR_TYPE::NUMBER['003001']] }, status: 422
    end
  end

  def destroy
    account_id = params[:id].to_i

    render_disallowed_to_delete_account_ids && return if disallowed_at_stock_account_ids?([account_id])
    render_disallowed_financier_ids && return if disallowed_at_stock_ids?([account_id])

    if @current_user.try(:at_user).try(:at_user_stock_accounts).pluck(:id).include?(account_id)
      Services::AtUserService.new(@current_user).delete_account(Entities::AtUserStockAccount, [account_id])
    end
    render json: {}, status: 204
  end

  private

  def get_account_params
    param = params.require(:stock_accounts).permit(:share, :name)
    {
        group_id: param[:share] == true ? @current_user.group_id : nil,
        share: param[:share] == true ? 1 : 0,
        name: param[:name],
    }
  end

  def create_activity_options(account)
    options = {}
    options[:goal] = nil
    options[:transaction] = nil
    options[:transactions] = nil
    options[:account] = account
    options
  end
end