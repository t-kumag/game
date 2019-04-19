class Api::V1::User::EmoneyTransactionsController < ApplicationController
    before_action :authenticate
    
    def index
        a = Entities::AtUserEmoneyServiceAccount.find(params[:emoney_account_id])
        @transactions = a.at_user_emoney_transactions.order(id: "DESC")
        render 'list', formats: 'json', handlers: 'jbuilder'
    end

    def show
        transaction = Entities::AtUserEmoneyTransactions.first(params[:id])
        @response = {
            amount: transaction.amount,
            category: transaction.at_transaction_category_id,
            used_date: transaction.used_date,
            payment_type: 'bank', # TODO enumにする
            used_store: transaction.description1,
            group: '',
        }
        render 'show', formats: 'json', handlers: 'jbuilder'
    end

    def update
        render 'update', formats: 'json', handlers: 'jbuilder'
    end

end
