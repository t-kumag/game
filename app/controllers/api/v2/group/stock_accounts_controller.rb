class Api::V2::Group::StockAccountsController < ApplicationController
  before_action :authenticate

  def index
    @responses = []
    share_on_stock_accounts = Entities::AtUserStockAccount.where(group_id: @current_user.group_id).where(share: true)
    if share_on_stock_accounts.present? && is_group?
      share_on_stock_accounts.each do |a|
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

end