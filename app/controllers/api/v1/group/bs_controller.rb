class Api::V1::Group::BsController < ApplicationController
  before_action :authenticate

  def summary
    bank_amount = 0
    emoney_amount = 0
    wallet_amount = 0
    stock_amount = 0

    share_on_bank_accounts = Services::AtBankTransactionService.new(@current_user).get_group_account()
    share_on_emoney_accounts = Services::AtEmoneyTransactionService.new(@current_user).get_group_account()
    share_on_stock_accounts = Services::AtStockTransactionService.new(@current_user).get_group_account()

    if share_on_bank_accounts
      bank_amount = share_on_bank_accounts.sum{|i| i.balance}
    end

    if share_on_emoney_accounts
      emoney_amount = share_on_emoney_accounts.sum{|i| i.balance}
    end

    if share_on_stock_accounts
      stock_amount = share_on_stock_accounts.sum{|i| i.balance}
    end

    wallets = Services::WalletTransactionService.new(@current_user).get_group_account()
    if wallets.present?
      wallet_amount = wallets.sum{|i| i.balance}
    end

    @response = {
        amount: bank_amount + emoney_amount + wallet_amount + stock_amount
    }
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end

end