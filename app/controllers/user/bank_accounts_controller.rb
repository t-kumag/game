class User::BankAccountsController < ApplicationController
    def index

        @result_json = {
            aaa: ''
        }
        render 'list', formats: 'json', handlers: 'jbuilder'
    end
end
