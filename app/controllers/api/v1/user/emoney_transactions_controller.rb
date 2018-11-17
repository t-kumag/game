class Api::V1::User::EmoneyTransactionsController < ApplicationController
    def index
        render 'list', formats: 'json', handlers: 'jbuilder'
    end

    def show
        render 'show', formats: 'json', handlers: 'jbuilder'
    end

    def update
        render 'update', formats: 'json', handlers: 'jbuilder'
    end

end