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

        t.string "branch_desc", null: false
        t.decimal "amount", precision: 16, scale: 2, null: false
        t.decimal "payment_amount", precision: 16, scale: 2, null: false
        t.string "trade_gubun", null: false
        t.string "etc_desc"
        t.string "clm_ym", null: false
        t.string "crdt_setl_dt"
        t.integer "seq", null: false
        t.string "card_no"
        t.bigint "at_transaction_category_id", null: false
        t.datetime "created_at", null: false
        t.datetime "updated_at", null: false
        t.string "confirm_type"
        t.index ["at_transaction_category_id"], name: "index_at_user_card_transactions_on_at_transaction_category_id"
        t.index ["at_user_card_account_id", "seq"], name: "at_user_card_transactions_at_user_card_account_id_seq", unique: true
        t.index ["at_user_card_account_id"], name: "index_at_user_card_transactions_on_at_user_card_account_id"

        render 'show', formats: 'json', handlers: 'jbuilder'
    end

    def update
        render 'update', formats: 'json', handlers: 'jbuilder'
    end

end
