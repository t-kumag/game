class Services::AtBankTransactionService
  def list(account_id)
    bank = Entities::AtUserBankAccount.find(account_id)
    bank.at_user_bank_transactions.order(id: "DESC")
  end

  def detail(account_id, transaction_id)
    transaction = Entities::AtUserBankTransaction.find transaction_id
    distributed = Entities::UserDistributedTransaction.find_by at_user_bank_transaction_id: transaction.id
    bank = Entities::AtUserBankAccount.find account_id
    category = Entities::AtTransactionCategory.find distributed.at_transaction_category_id

    {
      amount: distributed.amount,
      at_transaction_category_id: distributed.at_transaction_category_id,
      category_name1: category.category_name1,
      category_name2: category.category_name2,
      used_date: transaction.trade_date,
      used_location: distributed.used_location,
      is_shared: distributed.share,
      payment_name: bank.fnc_nm + bank.brn_nm,
    }
  end

  def update(transaction_id, category_id, used_location, is_shared)
    transaction = Entities::AtUserBankTransaction.find transaction_id
    distributed = Entities::UserDistributedTransaction.find_by at_user_bank_transaction_id: transaction.id
    distributed.at_transaction_category_id = category_id
    distributed.used_location = used_location
    distributed.share = is_shared
    distributed.save!
  end

end
