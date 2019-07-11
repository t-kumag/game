class Services::AtBankTransactionService

  def initialize(user)
    @user = user
  end

  # TODO: form toをつけないと検索範囲が広すぎる
  def list(account_id, page)
    bank = Entities::AtUserBankAccount.find_by(id: account_id, at_user_id: @user.at_user.id)
    result = bank.at_user_bank_transactions.order(id: "DESC")
    Kaminari.paginate_array(result).page(page)
  end

  def detail(account_id, transaction_id)
    transaction = Entities::AtUserBankTransaction.find_by(id: transaction_id, at_user_bank_account_id: @user.at_user.at_user_bank_accounts)
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
      is_shared: distributed&.at_user_bank_transaction&.at_user_bank_account&.share || distributed.share,
      payment_name: bank.fnc_nm + bank.brn_nm,
    }
  end

  def update(transaction_id, category_id, used_location, is_shared, group_id)
    transaction = Entities::AtUserBankTransaction.find_by(id: transaction_id, at_user_bank_account_id: @user.at_user.at_user_bank_accounts)
    distributed = Entities::UserDistributedTransaction.find_by at_user_bank_transaction_id: transaction.id
    distributed.at_transaction_category_id = category_id
    distributed.used_location = used_location
    distributed.group_id = group_id
    distributed.share = is_shared
    distributed.save!
  end

end
