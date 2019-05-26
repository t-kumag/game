class Api::V1::User::TransactionsController < ApplicationController
  before_action :authenticate

  def index
    @transactions = Entities::UserDistributedTransaction.where(user_id: @current_user.id, at_transaction_category_id: params[:category_id])
    @response = generate_response_from_transactions(@transactions)
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def grouped_transactions
    grouped_category = Entities::AtGroupedCategory.find params[:category_id]
    categories_in_group = Entities::AtTransactionCategory.where category_name1: grouped_category.category_name
    ids = categories_in_group.pluck(:id)
    @transactions = Entities::UserDistributedTransaction.where(user_id: @current_user.id, at_transaction_category_id: ids)
    @response = generate_response_from_transactions(@transactions)
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
  
  def type(transaction)
    return "bank" unless transaction.at_user_bank_transaction_id.nil?
    return "card" unless transaction.at_user_card_transaction_id.nil?
    return "emoney" unless transaction.at_user_emoney_transaction_id.nil?
  end

  def generate_response_from_transactions(transactions)
    response = []
    transactions.each{ |t|
      response << {
        amount: t.amount,
        used_date: t.used_date,
        used_location: t.used_location,
	transaction_id: t.at_user_bank_transaction_id || t.at_user_card_transaction_id || t.at_user_emoney_transaction_id,
	type: type(t)
      }
    }
    response
  end
end
