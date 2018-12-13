class Api::V1::User::CardAccountsController < ApplicationController
    before_action :authenticate

    def index
      if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_card_accounts.blank?
        @card_accounts = nil
      else
        @card_accounts = @current_user.at_user.at_user_card_accounts
      end    
      render 'list', formats: 'json', handlers: 'jbuilder'
    end
  
    def summary
      if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_card_accounts.blank?
        @response = {
          amount: 0,
        }
      else
        @response = {
          amount: @current_user.at_user.at_user_card_accounts.sum{|i| i.amount},
        }
      end
      render 'summary', formats: 'json', handlers: 'jbuilder'
    end
      
end
