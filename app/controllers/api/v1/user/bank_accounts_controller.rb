class Api::V1::User::BankAccountsController < ApplicationController
    def index
        @list = BankAccountService.list(@user.id)
        render 'list', formats: 'json', handlers: 'jbuilder'
    end

    def summary
        render 'summary', formats: 'json', handlers: 'jbuilder'
    end

end
