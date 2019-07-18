class Api::V1::Group::BankAccountsController < ApplicationController
  before_action :authenticate

  def index
    if @current_user.try(:at_user).try(:at_user_bank_accounts).blank?
      @responses = []
    else
      @responses = []

      share_on_bank_accounts =
          Entities::AtUserBankAccount.where(group_id: @current_user.group_id).where(share: true)
      share_on_bank_accounts.each do |a|
        @responses << {
            id: a.id,
            name: a.fnc_nm,
            amount: a.balance
        }
      end
    end
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def summary
    if @current_user.try(:at_user).try(:at_user_bank_accounts).blank?
      @response = {
          amount: 0,
      }
    else
      share_on_bank_accounts =
          Entities::AtUserBankAccount.where(group_id: @current_user.group_id).where(share: true)
      @response = {
          amount: share_on_bank_accounts.sum{|i| i.balance}
      }
    end
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end
end

