class Api::V1::User::TransactionsController < ApplicationController
  before_action :authenticate

  def index
    @transactions = Entities::UserDistributedTransaction.where(user_id: @current_user.id, at_transaction_category_id: params[:category_id])
    @response = []
    @transactions.each{ |t|
      @response << {
        amount: t.amount,
        used_date: t.used_date,
        used_location: t.used_location,
	transaction_id: t.at_user_bank_transaction_id || t.at_user_card_transaction_id || t.at_user_emoney_transaction_id,
	type: type(t)
      }
    }
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
  
  def type(transaction)
    return "bank" unless transaction.at_user_bank_transaction_id.nil?
    return "card" unless transaction.at_user_card_transaction_id.nil?
    return "emoney" unless transaction.at_user_emoney_transaction_id.nil?
  end
end
