class Api::V1::User::BankTransactionsController < ApplicationController
    before_action :authenticate
    def index
        id = params[:bank_account_id]

        p @current_user&.at_user&.at_user_bank_accounts.find(id)
        # if @current_user&.at_user.blank? || @current_user&.at_user&.at_user_bank_accounts.blank?
        #     @bank_accounts = nil
        #   else
        #     @bank_accounts = @current_user.at_user.at_user_bank_accounts
        # end
        render 'list', formats: 'json', handlers: 'jbuilder'
    end

    def show
        render 'show', formats: 'json', handlers: 'jbuilder'
    end

    def update
        render 'update', formats: 'json', handlers: 'jbuilder'
    end

end
