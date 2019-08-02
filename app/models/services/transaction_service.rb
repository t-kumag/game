class Services::TransactionService
  def initialize(user, category_id, share, with_group=false, page=1)
    @user = user
    @category_id = category_id
    @share = share == "true" ? true : false
    @with_group = with_group
    @page = page
  end

  def type(transaction)
    return "bank" unless transaction.at_user_bank_transaction_id.nil?
    return "card" unless transaction.at_user_card_transaction_id.nil?
    return "emoney" unless transaction.at_user_emoney_transaction_id.nil?
    return "manually_created" unless transaction.user_manually_created_transaction_id.nil?
  end

  def fetch_transactions(ids)
    # カテゴリ ID の指定がなければ全件抽出
    if ids.present?
      bank_tarnsactions   = Entities::UserDistributedTransaction.joins(:at_user_bank_transaction).includes(:at_user_bank_transaction).where(user_id: @user.id, at_transaction_category_id: ids)
      card_transactions   = Entities::UserDistributedTransaction.joins(:at_user_card_transaction).includes(:at_user_card_transaction).where(user_id: @user.id, at_transaction_category_id: ids)
      emoney_transactions = Entities::UserDistributedTransaction.joins(:at_user_emoney_transaction).includes(:at_user_emoney_transaction).where(user_id: @user.id, at_transaction_category_id: ids)
      user_manually_created_transactions = Entities::UserDistributedTransaction.joins(:user_manually_created_transaction).includes(:user_manually_created_transaction).where(user_id: @user.id, at_transaction_category_id: ids)
    else
      bank_tarnsactions   = Entities::UserDistributedTransaction.joins(:at_user_bank_transaction).includes(:at_user_bank_transaction).where(user_id: @user.id)
      card_transactions   = Entities::UserDistributedTransaction.joins(:at_user_card_transaction).includes(:at_user_card_transaction).where(user_id: @user.id)
      emoney_transactions = Entities::UserDistributedTransaction.joins(:at_user_emoney_transaction).includes(:at_user_emoney_transaction).where(user_id: @user.id)
      user_manually_created_transactions = Entities::UserDistributedTransaction.joins(:user_manually_created_transaction).includes(:user_manually_created_transaction).where(user_id: @user.id)
    end
    bank_tarnsactions + card_transactions + emoney_transactions + user_manually_created_transactions
  end

  def generate_response_from_transactions(transactions)

    response = []
    transactions.each{ |t|
      response << {
        at_user_bank_account_id:    t.at_user_bank_transaction.try(:at_user_bank_account_id),
        at_user_card_account_id:   t.at_user_card_transaction.try(:at_user_card_account_id),
        at_user_emoney_service_account_id: t.at_user_emoney_transaction.try(:at_user_emoney_service_account_id),
        at_transaction_category_id: t.at_transaction_category_id,
        is_shared: shared_account?(t) || t.share,
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
      transactions = fetch_transactions(ids)
      # 削除済み口座の明細を除外する
      transactions = remove_delete_account_transaction transactions
      # シェアしていない口座の明細 or シェアしていない明細を削除する
      transactions = remove_not_shared_transaction transactions
      transactions = generate_response_from_transactions transactions
      sort_by_used_date transactions
      Kaminari.paginate_array(transactions).page(@page)
    else
      if @share === true
        transactions = fetch_transactions(ids)
        # 削除済み口座の明細を除外する
        transactions = remove_delete_account_transaction transactions
        transactions = generate_response_from_transactions transactions
        sort_by_used_date transactions
        Kaminari.paginate_array(transactions).page(@page)
      else
        transactions = fetch_transactions(ids)
        # 削除済み口座の明細を除外する
        transactions = remove_delete_account_transaction transactions
        # シェアしている口座の明細 or シェアしている明細を削除する
        transactions = remove_shared_transaction transactions
        transactions = generate_response_from_transactions transactions
        sort_by_used_date transactions
        Kaminari.paginate_array(transactions).page(@page)
      end
    end
  end

  def remove_shared_transaction(transactions)
    transactions.reject do |t|
      if shared_account?(t) || t.share
        # シェアしている口座の明細 or シェアしている明細は削除する
        true
      else
        # シェアしていない口座の明細 or シェアしていない明細は削除しない
        false
      end
    end
  end

  def remove_not_shared_transaction(transactions)
    transactions.reject do |t|
      if shared_account?(t) || t.share
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

  def shared_account?(transaction)
    if transaction.try(:at_user_bank_transaction).try(:at_user_bank_account_id)
      shared_bank_account_ids = @user.at_user.at_user_bank_accounts.where(share: true).pluck(:id)
      shared_bank_account_ids.include?(transaction.at_user_bank_transaction.at_user_bank_account_id)
    elsif transaction.try(:at_user_card_transaction).try(:at_user_card_account_id)
      shared_card_account_ids =  @user.at_user.at_user_card_accounts.where(share: true).pluck(:id)
      shared_card_account_ids.include?(transaction.at_user_card_transaction.at_user_card_account_id)
    elsif transaction.try(:at_user_emoney_transaction).try(:at_user_emoney_service_account_id)
      shared_emoney_account_ids = @user.at_user.at_user_emoney_service_accounts.where(share: true).pluck(:id)
      shared_emoney_account_ids.include?(transaction.at_user_emoney_transaction.at_user_emoney_service_account_id)
    else
      # 手動明細は口座に紐づかないため口座シェア判定はfalse固定
      false
    end
  end
end
