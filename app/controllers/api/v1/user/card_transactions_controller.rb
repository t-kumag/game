class Api::V1::User::CardTransactionsController < ApplicationController

    def index
        ba = Entities::AtUserCardAcccount.first(params[:card_account_id])
        # TODO paging
        @transactions = ba.at_user_card_transactions
        render 'list', formats: 'json', handlers: 'jbuilder'
    end

    def show
        transaction = Entities::AtUserCardTransactions.first(params[:id])
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
