class CardAccountsController < ApplicationController
    def index
        render 'list', formats: 'json', handlers: 'jbuilder'
    end

    def summary
        render 'summary', formats: 'json', handlers: 'jbuilder'
    end
end
