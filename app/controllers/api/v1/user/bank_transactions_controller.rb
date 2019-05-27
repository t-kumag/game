class Api::V1::User::BankTransactionsController < ApplicationController
  before_action :authenticate
  # TODO(fujiura): before_action で対象口座へのアクセス権があるかチェックする
  # TODO(fujiura): bank_account_id, transaction_id に対応するデータがないときの処理

  def index
    bank = Entities::AtUserBankAccount.find(params[:bank_account_id])
    @transactions = bank.at_user_bank_transactions.order(id: "DESC")
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def show
    transaction = Entities::AtUserBankTransaction.find params[:id]
    distributed = Entities::UserDistributedTransaction.find_by at_user_bank_transaction_id: transaction.id
    bank = Entities::AtUserBankAccount.find params[:bank_account_id]
    category = Entities::AtTransactionCategory.find distributed.at_transaction_category_id

    @response = {
      amount: distributed.amount,
      at_transaction_category_id: distributed.at_transaction_category_id,
      category_name1: category.category_name1,
      category_name2: category.category_name2,
      used_date: transaction.trade_date,
      used_location: distributed.used_location,
      is_shared: distributed.share,
      payment_name: bank.fnc_nm + bank.brn_nm,
    }
    render 'show', formats: 'json', handlers: 'jbuilder'
  end

  def update
    transaction = Entities::AtUserBankTransaction.find params[:id]
    distributed = Entities::UserDistributedTransaction.find_by at_user_bank_transaction_id: transaction.id
    distributed.at_transaction_category_id = params[:at_transaction_category_id]
    distributed.used_location = params[:used_location]
    distributed.share = params[:is_shared]
    distributed.save!

    # TODO(fujiura): 何を返すべき？
    render 'update', formats: 'json', handlers: 'jbuilder'
  end

end
