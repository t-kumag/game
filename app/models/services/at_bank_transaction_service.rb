class Services::AtBankTransactionService

  def initialize(user, is_group=false)
    @user = user
    @is_group = is_group
  end

  # TODO: form toをつけないと検索範囲が広すぎる
  def list(account_id, page)
    distributed_transactions = get_distributed_transactions(account_id)
    result = distributed_transactions.order(at_user_bank_transaction_id: "DESC")
    Kaminari.paginate_array(result).page(page)
  end

  def detail(transaction_id)
    distributed = get_distributed_transaction(transaction_id)
    category = Entities::AtTransactionCategory.find distributed.at_transaction_category_id

    {
      amount: distributed.amount,
      at_transaction_category_id: distributed.at_transaction_category_id,
      category_name1: category.category_name1,
      category_name2: category.category_name2,
      used_date: distributed.at_user_bank_transaction.trade_date,
      used_location: distributed.used_location,
      is_shared: distributed.at_user_bank_transaction.at_user_bank_account.share || distributed.share,
      payment_name: distributed.at_user_bank_transaction.at_user_bank_account.fnc_nm + distributed.at_user_bank_transaction.at_user_bank_account.brn_nm,
    }
  end

  def update(transaction_id, category_id, used_location, is_shared, group_id)
    distributed = get_distributed_transaction(transaction_id)
    distributed.at_transaction_category_id = category_id
    distributed.used_location = used_location
    distributed.group_id = group_id
    distributed.share = is_shared
    distributed.save!
  end

  def get_distributed_transaction(transaction_id)
    distributed = Entities::UserDistributedTransaction.find_by(at_user_bank_transaction_id: transaction_id, user_id: @user.id)
    # グループ、且つシェアされていない口座の場合、シェアされている明細を取得
    if @is_group === true && distributed.at_user_bank_transaction.at_user_bank_account.share === false
      distributed = Entities::UserDistributedTransaction.find_by(at_user_bank_transaction_id: transaction_id, user_id: @user.id, share: true)
    end
    distributed
  end

  def get_distributed_transactions(account_id)
    bank = @user.at_user.at_user_bank_accounts.find(account_id)
    transaction_ids = bank.at_user_bank_transactions.pluck(:id)
    distributed_transactions = Entities::UserDistributedTransaction.where(at_user_bank_transaction_id: transaction_ids)
    # グループ、且つシェアされていない口座の場合、シェアされている全明細を取得
    if @is_group === true && bank.share === false
      distributed_transactions = Entities::UserDistributedTransaction.where(at_user_bank_transaction_id: transaction_ids, share: true)
    end
    distributed_transactions
  end

end
