class Services::TransactionService
  def initialize(user, category_id, share, scope=nil, with_group=false, from, to)
    @user = user
    @category_id = category_id
    @share = share == "true" ? true : false
    @with_group = with_group
    @scope = scope

    # from の 00:00:00 から to の 23:59:59 までのデータを取得
    # from/to の指定がなければ当月の月初から月末までのデータを取得
    @from = from ? Time.parse(from).beginning_of_day : Time.zone.today.beginning_of_month.beginning_of_day
    @to = to ? Time.parse(to).end_of_day : Time.zone.today.end_of_month.end_of_day
  end

  def type(transaction)
    return "bank" unless transaction.at_user_bank_transaction_id.nil?
    return "card" unless transaction.at_user_card_transaction_id.nil?
    return "emoney" unless transaction.at_user_emoney_transaction_id.nil?
    return "manually_created" unless transaction.user_manually_created_transaction_id.nil?
  end

  def fetch_transactions(ids, from, to)
    # カテゴリ ID の指定がなければ全件抽出
    if ids.present?
      bank_tarnsactions   = Entities::UserDistributedTransaction.joins(:at_user_bank_transaction).includes(:at_user_bank_transaction).where(user_id: @user.id, at_transaction_category_id: ids, used_date: from..to)
      card_transactions   = Entities::UserDistributedTransaction.joins(:at_user_card_transaction).includes(:at_user_card_transaction).where(user_id: @user.id, at_transaction_category_id: ids, used_date: from..to)
      emoney_transactions = Entities::UserDistributedTransaction.joins(:at_user_emoney_transaction).includes(:at_user_emoney_transaction).where(user_id: @user.id, at_transaction_category_id: ids, used_date: from..to)
      user_manually_created_transactions = Entities::UserDistributedTransaction.joins(:user_manually_created_transaction).includes(:user_manually_created_transaction).where(user_id: @user.id, at_transaction_category_id: ids, used_date: from..to)
    else
      bank_tarnsactions   = Entities::UserDistributedTransaction.joins(:at_user_bank_transaction).includes(:at_user_bank_transaction).where(user_id: @user.id, used_date: from..to)
      card_transactions   = Entities::UserDistributedTransaction.joins(:at_user_card_transaction).includes(:at_user_card_transaction).where(user_id: @user.id, used_date: from..to)
      emoney_transactions = Entities::UserDistributedTransaction.joins(:at_user_emoney_transaction).includes(:at_user_emoney_transaction).where(user_id: @user.id, used_date: from..to)
      user_manually_created_transactions = Entities::UserDistributedTransaction.joins(:user_manually_created_transaction).includes(:user_manually_created_transaction).where(user_id: @user.id, used_date: from..to)
    end
    bank_tarnsactions + card_transactions + emoney_transactions + user_manually_created_transactions
  end

  def generate_response_from_transactions(transactions, shared_accounts)

    response = []
    transactions.each{ |t|
      response << {
        at_user_bank_account_id:    t.at_user_bank_transaction.try(:at_user_bank_account_id),
        at_user_card_account_id:   t.at_user_card_transaction.try(:at_user_card_account_id),
        at_user_emoney_service_account_id: t.at_user_emoney_transaction.try(:at_user_emoney_service_account_id),
        at_transaction_category_id: t.at_transaction_category_id,
        is_shared: shared_account?(t, shared_accounts) || t.share,
        is_account_shared: shared_account?(t, shared_accounts),
        user_id: t.user_id,
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
    i = 0
    transactions.sort_by! { |a| [a[:used_date], i += 1] }.reverse!
  end

  def list(ids = @category_id)
    shared_accounts = get_shared_account_ids

    if @with_group === true
      transactions = fetch_transactions(ids, @from, @to)
      # 削除済み口座の明細を除外する
      transactions = remove_delete_account_transaction transactions
      # シェアしていない口座の明細 or シェアしていない明細を削除する
      transactions = remove_not_shared_transaction(transactions, shared_accounts)
      transactions = generate_response_from_transactions(transactions, shared_accounts)
      remove_scope_income(transactions)
      remove_scope_expence(transactions)
      sort_by_used_date transactions

    else
      transactions = fetch_transactions(ids, @from, @to)
      # 削除済み口座の明細を除外する
      transactions = remove_delete_account_transaction transactions
      # 家族共有OFFの場合、# シェアしている口座の明細 or シェアしている明細を削除する
      if @share === false
        transactions = remove_shared_transaction(transactions, shared_accounts)
      end
      transactions = generate_response_from_transactions(transactions, shared_accounts)
      remove_scope_income(transactions)
      remove_scope_expence(transactions)
      sort_by_used_date transactions
    end
  end

  def remove_scope_income(transactions)
    if @scope == "income"
      transactions.reject! {|t| t[:amount] < 0}
    end
  end

  def remove_scope_expence(transactions)
    if @scope == "expence"
      transactions.reject! {|t| t[:amount] > 0}
    end
  end

  def remove_shared_transaction(transactions, shared_accounts)
    transactions.reject do |t|
      if shared_account?(t, shared_accounts) || t.share
        # シェアしている口座の明細 or シェアしている明細は削除する
        true
      else
        # シェアしていない口座の明細 or シェアしていない明細は削除しない
        false
      end
    end
  end

  def remove_not_shared_transaction(transactions, shared_accounts)

    transactions.reject do |t|
      if shared_account?(t, shared_accounts) || t.share
        # シェアしている口座の明細 or シェアしている明細は削除しない
        false
      else
        # シェアしていない口座の明細 or シェアしていない明細は削除する
        true
      end
    end
  end

  def remove_delete_account_transaction(transactions)

    delete_bank_account_ids = Entities::AtUserBankAccount.with_deleted.where(at_user_id: @user.at_user.id).where.not(deleted_at: nil).pluck(:id)
    delete_card_account_ids = Entities::AtUserCardAccount.with_deleted.where(at_user_id: @user.at_user.id).where.not(deleted_at: nil).pluck(:id)
    delete_emoney_account_ids = Entities::AtUserEmoneyServiceAccount.with_deleted.where(at_user_id: @user.at_user.id).where.not(deleted_at: nil).pluck(:id)

    transactions.reject do |t|
      if t.try(:at_user_bank_transaction)
        delete_bank_account_ids.include?(t.at_user_bank_transaction.at_user_bank_account_id)
      elsif t.try(:at_user_card_transaction)
        delete_card_account_ids.include?(t.at_user_card_transaction.at_user_card_account_id)
      elsif t.try(:at_user_emoney_transaction)
        delete_emoney_account_ids.include?(t.at_user_emoney_transaction.at_user_emoney_service_account_id)
      else
        # 手動明細は口座に紐づかないため除外しない
        false
      end
    end
  end

  def grouped
    return list unless @category_id.present?
    grouped_category_name = Entities::AtGroupedCategory.find_by_id(@category_id).category_name
    return [] unless grouped_category_name.present?
    list Entities::AtTransactionCategory.where(category_name1: grouped_category_name).pluck(:id)
  end

  def shared_account?(transaction, shared_accounts)
    if transaction.try(:at_user_bank_transaction).try(:at_user_bank_account_id)
      shared_accounts[:bank_account_ids].include?(transaction.at_user_bank_transaction.at_user_bank_account_id)
    elsif transaction.try(:at_user_card_transaction).try(:at_user_card_account_id)
      shared_accounts[:card_account_ids].include?(transaction.at_user_card_transaction.at_user_card_account_id)
    elsif transaction.try(:at_user_emoney_transaction).try(:at_user_emoney_service_account_id)
      shared_accounts[:emoney_account_ids].include?(transaction.at_user_emoney_transaction.at_user_emoney_service_account_id)
    else
      # 手動明細は口座に紐づかないため口座シェア判定はfalse固定
      false
    end
  end

  def get_shared_account_ids
    shared = {}
    shared[:bank_account_ids] = @user.at_user.at_user_bank_accounts.where(share: true).pluck(:id)
    shared[:card_account_ids] =  @user.at_user.at_user_card_accounts.where(share: true).pluck(:id)
    shared[:emoney_account_ids] = @user.at_user.at_user_emoney_service_accounts.where(share: true).pluck(:id)
    shared
  end
end
