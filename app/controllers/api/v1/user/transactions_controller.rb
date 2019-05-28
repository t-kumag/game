class Api::V1::User::TransactionsController < ApplicationController
  before_action :authenticate

  def index
    # from の 00:00:00 から to の 23:59:59 までのデータを取得
    # from/to の指定がなければ当月の月初から月末までのデータを取得
    from = params[:from] ? Time.parse(params[:from]).beginning_of_day : Time.zone.today.beginning_of_month.beginning_of_day
    to = params[:to] ? Time.parse(params[:to]).end_of_day : Time.zone.today.end_of_month.end_of_day

    @transactions = fetch_transactions(from, to, params[:id])
    @response = generate_response_from_transactions(@transactions)
    render 'list', formats: 'json', handlers: 'jbuilder'
  end

  def grouped_transactions
    # from の 00:00:00 から to の 23:59:59 までのデータを取得
    # from/to の指定がなければ当月の月初から月末までのデータを取得
    from = params[:from] ? Time.parse(params[:from]).beginning_of_day : Time.zone.today.beginning_of_month.beginning_of_day
    to = params[:to] ? Time.parse(params[:to]).end_of_day : Time.zone.today.end_of_month.end_of_day

    # 大項目を取得し、大項目に対応する AT カテゴリを取得し、AT カテゴリに対応する明細を WHERE IN で取得する
    # 大項目のカテゴリー ID が指定されていなければ全件抽出
    if params[:category_id].present?
      grouped_category = Entities::AtGroupedCategory.find_by_id params[:category_id]
      if (grouped_category.present?)
        categories_in_group = Entities::AtTransactionCategory.where category_name1: grouped_category.category_name
        ids = categories_in_group.pluck(:id)
        @transactions = fetch_transactions(from, to, ids)
      else
        @transactions = []
      end
    else
      @transactions = fetch_transactions(from, to)
    end

    @response = generate_response_from_transactions(@transactions)
    render 'list', formats: 'json', handlers: 'jbuilder'
  end
  
  def type(transaction)
    return "bank" unless transaction.at_user_bank_transaction_id.nil?
    return "card" unless transaction.at_user_card_transaction_id.nil?
    return "emoney" unless transaction.at_user_emoney_transaction_id.nil?
  end

  def fetch_transactions(from, to, ids = nil)
    transactions = nil
    # カテゴリ ID の指定がなければ全件抽出
    if ids.present?
      transactions = Entities::UserDistributedTransaction.where(user_id: @current_user.id, at_transaction_category_id: ids, used_date: from..to)
    else
      transactions = Entities::UserDistributedTransaction.where(user_id: @current_user.id, used_date: from..to)
    end
    transactions
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
