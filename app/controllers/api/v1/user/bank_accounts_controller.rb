class Api::V1::User::BankAccountsController < ApplicationController
  def index
    # user = Entities::User.find(1)
    # @bank_accounts = user.at_user.at_user_bank_accounts
    @response = {
      accounts: [
      {
        account_id:   1,
        card_name: "三井住友銀行",
        amount: 11111,
        error: "連携が切れました。"},
      ]
    }
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def summary
    @response = {
      amount: 11111,
    }
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end

end

