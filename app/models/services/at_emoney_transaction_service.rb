class Services::AtEmoneyTransactionService

  def initialize(user, is_group=false)
    @user = user
    @is_group = is_group
  end

  # TODO: form toをつけないと検索範囲が広すぎる
  def list(account_id, page)
    distributed_transactions = get_distributed_transactions(account_id)
    return {} if distributed_transactions.blank?

    result = distributed_transactions.order(at_user_emoney_transaction_id: "DESC")
    Kaminari.paginate_array(result).page(page)
  end

  def detail(account_id, transaction_id)
    distributed = get_distributed_transaction(account_id, transaction_id)
    return {} if distributed.blank?

    category = Entities::AtTransactionCategory.find distributed.at_transaction_category_id

    {
      amount: distributed.amount,
      at_transaction_category_id: distributed.at_transaction_category_id,
      category_name1: category.category_name1,
      category_name2: category.category_name2,
      used_date: distributed.at_user_emoney_transaction.used_date,
      used_location: distributed.used_location,
      is_shared: distributed.at_user_emoney_transaction.at_user_emoney_service_account.share || distributed.share,
      # emoney の場合 brn_nm は存在せず、fnc_nm のみ
      payment_name: distributed.at_user_emoney_transaction.at_user_emoney_service_account.fnc_nm,
    }
  end

  def update(account_id, transaction_id, category_id, used_location, is_shared, group_id)
    distributed = get_distributed_transaction(account_id, transaction_id)
    return {} if distributed.blank?

    distributed.at_transaction_category_id = category_id
    distributed.used_location = used_location
    distributed.group_id = group_id
    distributed.share = is_shared
    distributed.save!
  end

  def get_distributed_transaction(account_id, transaction_id)
    if @is_group === true
      emoney = Entities::AtUserEmoneyServiceAccount.find_by(id: account_id, at_user_id: [@user.at_user.id, @user.partner_user.at_user.id])
    else
      emoney = Entities::AtUserEmoneyServiceAccount.find_by(id: account_id, at_user_id: @user.at_user.id, share: false)
    end
    return {} if emoney.blank?
    
    transaction = Entities::AtUserEmoneyTransaction.find_by(id: transaction_id, at_user_emoney_service_account_id: emoney.id)
    return {} if transaction.blank?

    if @is_group === true
      if emoney.share === true
        distributed = transaction.user_distributed_transaction
      else
        distributed = Entities::UserDistributedTransaction.find_by(at_user_emoney_transaction_id: transaction.id, share: true)
      end
    else
      distributed = Entities::UserDistributedTransaction.find_by(at_user_emoney_transaction_id: transaction.id, share: false)
    end
    distributed
  end

  def get_distributed_transactions(account_id)
    if @is_group === true
      emoney = Entities::AtUserEmoneyServiceAccount.find_by(id: account_id, at_user_id: [@user.at_user.id, @user.partner_user.at_user.id])
    else
      emoney = Entities::AtUserEmoneyServiceAccount.find_by(id: account_id, at_user_id: @user.at_user.id, share: false)
    end
    return {} if emoney.blank?

    transaction_ids = emoney.at_user_emoney_transactions.pluck(:id)
    return {} if transaction_ids.blank?

    if @is_group === true
      if emoney.share === true
        distributed_transactions = Entities::UserDistributedTransaction.where(at_user_emoney_transaction_id: transaction_ids)
      else
        distributed_transactions = Entities::UserDistributedTransaction.where(at_user_emoney_transaction_id: transaction_ids, share: true)
      end
    else
      distributed_transactions = Entities::UserDistributedTransaction.where(at_user_emoney_transaction_id: transaction_ids, share: false)
    end
    distributed_transactions
  end

end
