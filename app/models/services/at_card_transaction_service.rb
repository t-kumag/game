class Services::AtCardTransactionService

  # TODO: form toをつけないと検索範囲が広すぎる
  def list(account_id, page)
    card = Entities::AtUserCardAccount.find(account_id)
    result = card.at_user_card_transactions.order(id: "DESC")
    Kaminari.paginate_array(result).page(page)
  end

  def detail(account_id, transaction_id)
    transaction = Entities::AtUserCardTransaction.find transaction_id
    distributed = Entities::UserDistributedTransaction.find_by at_user_card_transaction_id: transaction.id
    card = Entities::AtUserCardAccount.find account_id
    category = Entities::AtTransactionCategory.find distributed.at_transaction_category_id

    {
      amount: distributed.amount,
      at_transaction_category_id: distributed.at_transaction_category_id,
      category_name1: category.category_name1,
      category_name2: category.category_name2,
      used_date: transaction.used_date,
      used_location: distributed.used_location,
      is_shared: distributed.share,
      payment_name: card.fnc_nm + card.brn_nm,
    }
  end

  def update(transaction_id, category_id, used_location, is_shared, group_id)
    transaction = Entities::AtUserCardTransaction.find transaction_id
    distributed = Entities::UserDistributedTransaction.find_by at_user_card_transaction_id: transaction.id
    distributed.at_transaction_category_id = category_id
    distributed.used_location = used_location
    distributed.group_id = group_id
    distributed.share = is_shared
    distributed.save!
  end

end
