class Api::V1::Group::BsController < ApplicationController
  before_action :authenticate

  def summary
    bank_amount = 0
    emoney_amount = 0
    wallet_amount = 0
    stock_amount = 0

    share_on_bank_accounts = Entities::AtUserBankAccount.where(group_id: @current_user.group_id).where(share: true)
    share_on_emoney_accounts = Entities::AtUserEmoneyServiceAccount.where(group_id: @current_user.group_id).where(share: true)
    share_on_stock_accounts = Entities::AtUserStockAccount.where(group_id: @current_user.group_id).where(share: true)

    if share_on_bank_accounts && is_group?
      bank_amount = share_on_bank_accounts.sum{|i| i.balance}
    end

    if share_on_emoney_accounts && is_group?
      emoney_amount = share_on_emoney_accounts.sum{|i| i.balance}
    end

    if share_on_stock_accounts && is_group?
      stock_amount = share_on_stock_accounts.sum{|i| i.balance}
    end

    wallets =  Entities::Wallet.where(group_id: @current_user.group_id).where(share: true)
    if wallets.present? && is_group?
      wallet_amount = wallets.sum{|i| i.balance}
    end

    @response = {
        amount: bank_amount + emoney_amount + wallet_amount + stock_amount
    }
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end

end