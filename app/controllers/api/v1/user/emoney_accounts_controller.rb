class Api::V1::User::EmoneyAccountsController < ApplicationController
    before_action :authenticate

    def index
      if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_emoney_service_accounts.blank?
        @emoney_service_accounts = nil
      else
        @emoney_service_accounts = @current_user.at_user.at_user_emoney_service_accounts
      end    
      render 'list', formats: 'json', handlers: 'jbuilder'
    end
  
    def summary
      if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_emoney_service_accounts.blank?
        @response = {
          amount: 0,
        }
      else
        @response = {
          amount: @current_user.at_user.at_user_emoney_service_accounts.sum{|i| i.amount},
        }
      end
      render 'summary', formats: 'json', handlers: 'jbuilder'
    end
      
end
