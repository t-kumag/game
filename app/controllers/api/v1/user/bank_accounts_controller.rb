class Api::V1::User::BankAccountsController < ApplicationController
    def index
        user = Entities::User.find(1)
        @bank_accounts = user.at_user.at_user_bank_accounts
        render 'list', formats: 'json', handlers: 'jbuilder'
    end

    def summary
        render 'summary', formats: 'json', handlers: 'jbuilder'
    end

end
