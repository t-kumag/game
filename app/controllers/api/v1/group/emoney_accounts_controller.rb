class Api::V1::User::EmoneyAccountsController < ApplicationController
    before_action :authenticate

    def index
      if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_emoney_service_accounts.blank?
        @responses = []
      else
        @responses = []
        @current_user.at_user.at_user_emoney_service_accounts.each do |a|
          @responses << {
            id: a.id,
            name: a.fnc_nm,
            amount: a.balance
          }
        end
      end
      render 'list', formats: 'json', handlers: 'jbuilder'
    end

end
