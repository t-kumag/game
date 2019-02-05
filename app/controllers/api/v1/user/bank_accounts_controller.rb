class Api::V1::User::BankAccountsController < ApplicationController
  before_action :authenticate

  def index
    if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_bank_accounts.blank?
      @responses = []
    else
      @responses = []
      @current_user.at_user.at_user_bank_accounts.each do |a|
        @responses << {
          id: a.id,
          name: a.fnc_nm,
          amount: 0
          # a.at_user_bank_transactions.last.balance
        }
      end
    end
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def summary
    if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_bank_accounts.blank?
      @response = {
        amount: 0,
      }
    else
      @response = {
        amount: @current_user.at_user.at_user_bank_accounts.sum{|i| i.balance},
      }
    end
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end

end

