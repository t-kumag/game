class Api::V1::Group::BankAccountsController < ApplicationController
  before_action :authenticate

  def index
    share = false || params[:share]
    if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_bank_accounts.blank?
      @responses = []
    else
      @responses = []

      @current_user.at_user.at_user_bank_accounts.each do |a|
        @responses << {
            id: a.id,
            name: a.fnc_nm,
            amount: a.balance
        }
      end
    end
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  # TODO 目標金額の足しこみが必要
  def summary
    share = false || params[:share]
    if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_bank_accounts.blank?
      @response = {
          amount: 0,
      }
    else
      amount = if share
                 # shareを含む場合
                 @current_user.at_user.at_user_bank_accounts.sum{|i| i.balance}
               else
                 @current_user.at_user.at_user_bank_accounts.where(at_user_bank_accounts: {share: false}).sum{|i| i.balance}
               end
      @response = {
          amount: amount
      }
    end
    render 'summary', formats: 'json', handlers: 'jbuilder'
  end


end

