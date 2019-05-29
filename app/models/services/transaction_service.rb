class Services::TransactionService
  def initialize(user_id, from, to, category_id)
    @user_id = user_id

    # from の 00:00:00 から to の 23:59:59 までのデータを取得
    # from/to の指定がなければ当月の月初から月末までのデータを取得
    @from = from ? Time.parse(from).beginning_of_day : Time.zone.today.beginning_of_month.beginning_of_day
    @to = to ? Time.parse(to).end_of_day : Time.zone.today.end_of_month.end_of_day
    @category_id = category_id
  end

  def type(transaction)
    return "bank" unless transaction.at_user_bank_transaction_id.nil?
    return "card" unless transaction.at_user_card_transaction_id.nil?
    return "emoney" unless transaction.at_user_emoney_transaction_id.nil?
  end

  def fetch_transactions(from, to, ids)
    transactions = nil
    # カテゴリ ID の指定がなければ全件抽出
    if ids.present?
      transactions = Entities::UserDistributedTransaction.where(user_id: @user_id, at_transaction_category_id: ids, used_date: from..to)
    else
      transactions = Entities::UserDistributedTransaction.where(user_id: @user_id, used_date: from..to)
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

  def list(ids = @category_id)
    transactions = fetch_transactions(@from, @to, ids)
    generate_response_from_transactions transactions
  end

  def grouped
    if @category_id.present?
      grouped_category = Entities::AtGroupedCategory.find_by_id @category_id
      if (grouped_category.present?)
        categories_in_group = Entities::AtTransactionCategory.where category_name1: grouped_category.category_name
        ids = categories_in_group.pluck(:id)
        list ids
      else
        return []
      end
    else
      list
    end
  end
end
