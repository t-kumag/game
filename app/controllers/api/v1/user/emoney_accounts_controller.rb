class Api::V1::User::EmoneyAccountsController < ApplicationController
    def index
        render 'list', formats: 'json', handlers: 'jbuilder'
    end

    def summary
        @response = {
            amount: 100000
        }
        render 'summary', formats: 'json', handlers: 'jbuilder'
    end
end
