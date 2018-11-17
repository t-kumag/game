class Api::V1::User::CardAccountsController < ApplicationController
    def index
        render 'list', formats: 'json', handlers: 'jbuilder'
    end

    def summary
        render 'summary', formats: 'json', handlers: 'jbuilder'
    end
end
