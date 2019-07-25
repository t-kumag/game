class Services::TransactionService
  def initialize(user_id, from, to, category_id, share, with_group=false)
    @user_id = user_id

    # from の 00:00:00 から to の 23:59:59 までのデータを取得
    # from/to の指定がなければ当月の月初から月末までのデータを取得
    @from = from ? Time.parse(from).beginning_of_day : Time.zone.today.beginning_of_month.beginning_of_day
    @to = to ? Time.parse(to).end_of_day : Time.zone.today.end_of_month.end_of_day
    @category_id = category_id
    @share = share
    @with_group = with_group
  end

  def type(transaction)
    return "bank" unless transaction.at_user_bank_transaction_id.nil?
    return "card" unless transaction.at_user_card_transaction_id.nil?
    return "emoney" unless transaction.at_user_emoney_transaction_id.nil?
    return "manually_created" unless transaction.user_manually_created_transaction_id.nil?
  end

  def fetch_transactions(from, to, ids)
    # カテゴリ ID の指定がなければ全件抽出
    if ids.present?
      bank_tarnsactions   = Entities::UserDistributedTransaction.joins(:at_user_bank_transaction).includes(:at_user_bank_transaction).where(user_id: @user_id, at_transaction_category_id: ids, used_date: from..to)
      card_transactiohs   = Entities::UserDistributedTransaction.joins(:at_user_card_transaction).includes(:at_user_card_transaction).where(user_id: @user_id, at_transaction_category_id: ids, used_date: from..to)
      emoney_transactiohs = Entities::UserDistributedTransaction.joins(:at_user_emoney_transaction).includes(:at_user_emoney_transaction).where(user_id: @user_id, at_transaction_category_id: ids, used_date: from..to)
      user_manually_created_transaction = Entities::UserDistributedTransaction.includes(:user_manually_created_transaction).where(user_id: @user_id, at_transaction_category_id: ids, used_date: from..to)
    else
      bank_tarnsactions   = Entities::UserDistributedTransaction.joins(:at_user_bank_transaction).includes(:at_user_bank_transaction).where(user_id: @user_id, used_date: from..to)
      card_transactiohs   = Entities::UserDistributedTransaction.joins(:at_user_card_transaction).includes(:at_user_card_transaction).where(user_id: @user_id, used_date: from..to)
      emoney_transactiohs = Entities::UserDistributedTransaction.joins(:at_user_emoney_transaction).includes(:at_user_emoney_transaction).where(user_id: @user_id, used_date: from..to)
      user_manually_created_transaction = Entities::UserDistributedTransaction.joins(:user_manually_created_transaction).includes(:user_manually_created_transaction).where(user_id: @user_id, used_date: from..to)
    end
    bank_tarnsactions + card_transactiohs + emoney_transactiohs + user_manually_created_transaction
  end

  def generate_response_from_transactions(transactions)

    response = []
    transactions.each{ |t|
      response << {
        at_user_bank_account_id:    t.at_user_bank_transaction.try(:at_user_bank_account_id),
        at_user_card_account_id:   t.at_user_card_transaction.try(:at_user_card_account_id),
        at_user_emoney_service_account_id: t.at_user_emoney_transaction.try(:at_user_emoney_service_account_id),
        amount: t.amount,
        used_date: t.used_date,
        used_location: t.used_location,
        transaction_id: t.at_user_bank_transaction_id || t.at_user_card_transaction_id || t.at_user_emoney_transaction_id || t.user_manually_created_transaction_id,
        type: type(t)
      }
    }
    response
  end

  def sort_by_used_date(transactions)
    transactions.sort_by! { |a| a[:used_date] }.reverse!
  end

  def list(ids = @category_id)
    if @with_group === true
      transactions = fetch_transactions(@from, @to, ids)
      # シェアしていない口座の明細 or シェアしていない明細を削除する
      transactions = remove_not_shared_transaction transactions
      transactions = generate_response_from_transactions transactions
      sort_by_used_date transactions
    else
      if @share === true
        transactions = fetch_transactions(@from, @to, ids)
        transactions = generate_response_from_transactions transactions
        sort_by_used_date transactions
      else
        transactions = fetch_transactions(@from, @to, ids)
        # シェアしている口座の明細 or シェアしている明細を削除する
        transactions = remove_shared_transaction transactions
        transactions = generate_response_from_transactions transactions
        sort_by_used_date transactions
      end
    end
  end

  def remove_shared_transaction(transactions)
    # シェアしている口座の明細 or シェアしている明細を削除する
    transactions.reject do |t|
      # シェアしている明細を削除する
      if t.share === true
        true
      else
        # シェアしていない明細、且つシェアしている口座
        if t.try(:at_user_bank_transaction)
          # 銀行
          t.at_user_bank_transaction.at_user_bank_account.share === true 
        elsif t.try(:at_user_card_transaction)
          # カード
          t.at_user_card_transaction.at_user_card_account.share === true
        elsif t.try(:at_user_emoney_transaction)
          # 電子マネー
          t.at_user_emoney_transaction.at_user_emoney_service_account.share === true
        else
          # シェアしていない手動明細は除外しない
          false
        end
      end
    end
  end

  def remove_not_shared_transaction(transactions)
    # シェアしていない口座の明細 or シェアしていない明細を削除する
    transactions.reject do |t|
      # シェアしている明細を削除しない
      if t.share === true
        false
      else
        # シェアしていない明細、且つシェアしていない口座
        if t.try(:at_user_bank_transaction)
          # 銀行
          t.at_user_bank_transaction.at_user_bank_account.share === false
        elsif t.try(:at_user_card_transaction)
          # カード
          t.at_user_card_transaction.at_user_card_account.share === false
        elsif t.try(:at_user_emoney_transaction)
          # 電子マネー
          t.at_user_emoney_transaction.at_user_emoney_service_account.share === false
        else
          # シェアしていない手動明細は除外する
          true
        end
      end
    end
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
