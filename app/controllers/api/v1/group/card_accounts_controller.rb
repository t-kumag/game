class Api::V1::Group::CardAccountsController < ApplicationController
    before_action :authenticate

    def index
      share = false || params[:share]
      if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_card_accounts.blank?
        @responses = []
      else
        @responses = []

        accounts = if share
                     @current_user.at_user.at_user_card_accounts
                   else
                     @current_user.at_user.at_user_card_accounts.where(at_user_card_accounts: {share: false})
                   end

        accounts.each do |ca|
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
      share = false || params[:share]
      if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_card_accounts.blank?
        @response = {
            amount: 0,
        }
      else
        amount = if share
                   # shareを含む場合
                   @current_user.at_user.at_user_card_accounts.sum{|i| i.current_month_payment}
                 else
                   @current_user.at_user.at_user_card_accounts.where(at_user_card_accounts: {share: false}).sum{|i| i.current_month_payment}
                 end
        @response = {
            amount: amount
        }
      end
      render 'summary', formats: 'json', handlers: 'jbuilder'
    end
      
end
