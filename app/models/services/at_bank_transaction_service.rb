class Services::AtBankTransactionService

  def initialize(user, is_group=false, from=nil, to=nil)
    @user = user
    @is_group = is_group

    # from の 00:00:00 から to の 23:59:59 までのデータを取得
    # from/to の指定がなければ当月の月初から月末までのデータを取得
    @from = from ? Time.parse(from).beginning_of_day : Time.zone.today.beginning_of_month.beginning_of_day
    @to = to ? Time.parse(to).end_of_day : Time.zone.today.end_of_month.end_of_day
  end

  # TODO: form toをつけないと検索範囲が広すぎる
  def list(account_id, page)
    distributed_transactions = get_distributed_transactions(account_id)
    return {} if distributed_transactions.blank?

    result = distributed_transactions.where(created_at: @from..@to).order(used_date: "DESC")
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
      used_date: distributed.at_user_bank_transaction.trade_date,
      used_location: distributed.used_location,
      is_shared: distributed.at_user_bank_transaction.at_user_bank_account.share || distributed.share,
      payment_name: distributed.at_user_bank_transaction.at_user_bank_account.fnc_nm + distributed.at_user_bank_transaction.at_user_bank_account.brn_nm,
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
      bank = Entities::AtUserBankAccount.find_by(id: account_id, at_user_id: [@user.at_user.id, @user.partner_user.try(:at_user).try(:id)])
    else
      bank = Entities::AtUserBankAccount.find_by(id: account_id, at_user_id: @user.at_user.id, share: false)
    end
    return {} if bank.blank?
    
    transaction = Entities::AtUserBankTransaction.find_by(id: transaction_id, at_user_bank_account_id: bank.id)
    return {} if transaction.blank?

    if @is_group === true
      if bank.share === true
        distributed = transaction.user_distributed_transaction
      else
        distributed = Entities::UserDistributedTransaction.find_by(at_user_bank_transaction_id: transaction.id, share: true)
      end
    else
      distributed = Entities::UserDistributedTransaction.find_by(at_user_bank_transaction_id: transaction.id, share: false)
    end
    distributed
  end

  def get_distributed_transactions(account_id)
    if @is_group === true
      bank = Entities::AtUserBankAccount.find_by(id: account_id, at_user_id: [@user.at_user.id, @user.partner_user.try(:at_user).try(:id)])
    else
      bank = Entities::AtUserBankAccount.find_by(id: account_id, at_user_id: @user.at_user.id, share: false)
    end
    return {} if bank.blank?

    transaction_ids = bank.at_user_bank_transactions.pluck(:id)
    return {} if transaction_ids.blank?

    if @is_group === true
      if bank.share === true
        distributed_transactions = Entities::UserDistributedTransaction.where(at_user_bank_transaction_id: transaction_ids)
      else
        distributed_transactions = Entities::UserDistributedTransaction.where(at_user_bank_transaction_id: transaction_ids, share: true)
      end
    else
      distributed_transactions = Entities::UserDistributedTransaction.where(at_user_bank_transaction_id: transaction_ids, share: false)
    end
    distributed_transactions
  end

end
