class Api::V1::User::BankTransactionsController < ApplicationController
    before_action :authenticate

    def index
        ba = Entities::AtUserBankAcccount.first(params[:bank_account_id])
        # TODO paging
        @transactions = ba.at_user_bank_transactions
        render 'list', formats: 'json', handlers: 'jbuilder'
    end

    def show
        transaction = Entities::AtUserBankTransactions.first(params[:id])
        @response = {
            amount: transaction.amount,
            category: transaction.at_transaction_category_id,
            used_date: transaction.trade_date,
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
