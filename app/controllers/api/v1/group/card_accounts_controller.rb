class Api::V1::User::CardAccountsController < ApplicationController
    before_action :authenticate

    def index
      if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_card_accounts.blank?
        @responses = []
      else
        @responses = []
        @current_user.at_user.at_user_card_accounts.each do |ca|
          @responses << {
            id: ca.id,
            name: ca.fnc_nm,
            amount: ca.current_month_payment
          }
        end
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
          amount: @current_user.at_user.at_user_card_accounts.sum{|i| i.current_month_payment},
        }
      end
      render 'summary', formats: 'json', handlers: 'jbuilder'
    end
      
end
