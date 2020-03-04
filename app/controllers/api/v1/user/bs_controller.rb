class Api::V1::User::BsController < ApplicationController
  before_action :authenticate

  def summary
    bank_amount = 0
    emoney_amount = 0
    wallet_amount = 0
    stock_amount = 0

    if @current_user.try(:at_user).try(:at_user_bank_accounts)
      at_bank_accounts = @current_user.try(:at_user).try(:at_user_bank_accounts).where(at_user_bank_accounts: {share: false})
    end

    if @current_user.try(:at_user).try(:at_user_emoney_service_accounts)
      at_emoney_accounts = @current_user.try(:at_user).try(:at_user_emoney_service_accounts).where(at_user_emoney_service_accounts: {share: false})
    end

    if @current_user.try(:at_user).try(:at_user_stock_accounts)
      at_stock_accounts = @current_user.try(:at_user).try(:at_user_stock_accounts).where(at_user_stock_accounts: {share: false})
    end

    if at_bank_accounts
      bank_amount = at_bank_accounts.sum{|i| i.balance}
    end
    
    if at_emoney_accounts
      emoney_amount = at_emoney_accounts.sum{|i| i.balance}
    end

    if at_stock_accounts
      stock_amount = at_stock_accounts.sum{|i| i.balance}
    end

    wallets = Entities::Wallet.where(user_id: @current_user.id).where(share: false)
    if wallets.present?
      wallet_amount = wallets.sum{|i| i.balance}
    end

    @response = {
        amount: bank_amount + emoney_amount + wallet_amount + stock_amount
    }
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end

end
