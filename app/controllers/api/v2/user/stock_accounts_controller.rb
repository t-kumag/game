class Api::V2::User::StockAccountsController < ApplicationController
  before_action :authenticate

  def index
    @responses = []
    if @current_user.try(:at_user).present? && @current_user.try(:at_user).try(:at_user_stock_accounts).present?
      @current_user.at_user.at_user_stock_accounts.where(share: false).each do |a|
      @responses << {
          id: a.id,
          name: a.fnc_nm,
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
      require_group && return if params[:share] == true
      account = Entities::AtUserStockAccount.find account_id
      account.update!(get_account_params)
      render json: {}, status: 204
    else
      # TODO(fujiura): code の検討と、エラー処理共通化
      render json: { errors: { code: '', mesasge: "account not found." } }, status: 200
    end
  end

  def destroy
    account_id = params[:id].to_i

    render_disallowed_account_ids && return if disallowed_at_stock_account_ids?([account_id])
    render_disallowed_financier_ids && return if disallowed_at_stock_ids?([account_id])

    if @current_user.try(:at_user).try(:at_user_stock_accounts).pluck(:id).include?(account_id)
      Services::AtUserService.new(@current_user).delete_account(Entities::AtUserStockAccount, [account_id])
    end
    render json: {}, status: 204
  end

  private

  def get_account_params
    param = params.require(:stock_accounts).permit(:share)
    {
        group_id: @current_user.group_id,
        share: param[:share],
    }
  end
end