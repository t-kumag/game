class Services::WalletTransactionService
  def initialize(user, is_group = false, from = nil, to = nil)
    @user = user
    @is_group = is_group
    @from = from ? Time.zone.parse(from).beginning_of_day : Time.zone.today.beginning_of_month.beginning_of_day
    @to = to ? Time.zone.parse(to).end_of_day : Time.zone.today.end_of_month.end_of_day
  end

  def list(wallet_id)
    get_distributed_transactions(wallet_id)
  end

  def detail(wallet_id, transaction_id)
    get_distributed_transaction(wallet_id, transaction_id)
  end

  def update(wallet_id, transaction_id, category_id, used_location, is_shared, group_id)
    distributed = get_distributed_transaction(wallet_id, transaction_id)
    return {} if distributed[:user_distributed_transaction].blank?

    distributed[:user_distributed_transaction].at_transaction_category_id = category_id
    distributed[:user_distributed_transaction].used_location = used_location
    distributed[:user_distributed_transaction].group_id = group_id
    distributed[:user_distributed_transaction].share = is_shared
    distributed[:user_distributed_transaction].save!
    distributed
  end

  def get_distributed_transaction(wallet_id, transaction_id)
    transaction = {}
    wallet = if @is_group === true
               Entities::Wallet.find_by(id: wallet_id, group_id: @user.group_id, share: true)
             else
               Entities::Wallet.find_by(id: wallet_id, user_id: @user.id, share: false)
             end
    return {} if wallet.blank?

    wallet_transaction = Entities::UserManuallyCreatedTransaction.find(transaction_id)
    transaction[:is_account_shared] = wallet.share
    transaction[:user_distributed_transaction] = Entities::UserDistributedTransaction.
                                                 joins(:at_transaction_category).
                                                 includes(:at_transaction_category).
                                                 find_by(user_manually_created_transaction_id: wallet_transaction.id)

    # TODO: BS PL 利用明細から参照されるため、参照元に合わせて処理する必要がある。
    # distributed = Entities::UserDistributedTransaction.find_by(at_user_bank_transaction_id: transaction.id) unless @is_group === true
    # if bank.share === true
    #   distributed = transaction.user_distributed_transaction
    # else
    #   distributed = Entities::UserDistributedTransaction.find_by(at_user_bank_transaction_id: transaction.id)
    # end
    # distributed

    return {} if transaction.blank?
    {
      amount: transaction[:user_distributed_transaction].amount,
      at_transaction_category_id: transaction[:user_distributed_transaction].at_transaction_category_id,
      category_name1: transaction[:user_distributed_transaction].at_transaction_category.category_name1,
      category_name2: transaction[:user_distributed_transaction].at_transaction_category.category_name2,
      used_date: transaction[:user_distributed_transaction].used_date,
      used_location: transaction[:user_distributed_transaction].used_location,
      memo: transaction[:user_distributed_transaction].memo,
      user_id: transaction[:user_distributed_transaction].user_id,
      is_account_shared: transaction[:is_account_shared],
      is_shared: wallet.share || transaction[:user_distributed_transaction].share,
      payment_name: wallet.name,
      transaction_id: transaction[:user_distributed_transaction].user_manually_created_transaction_id,
      payment_method_id: wallet_transaction.payment_method_id,
      payment_method_type: wallet_transaction.payment_method_type
    }
  end

  def get_distributed_transactions(wallet_id)
    transactions = {}
    wallet = if @is_group === true
               Entities::Wallet.find_by(id: wallet_id, group_id: @user.group_id, share: true)
             else
               Entities::Wallet.find_by(id: wallet_id, user_id: @user.id, share: false)
             end
    return {} if wallet.blank?
    transactions[:is_account_shared] = wallet.share

    # Pager
    # 昨日から90日以内に明細があればその最新を返す。AT仕様に合わせて90日以上は考慮しない
    next_transaction = Entities::UserManuallyCreatedTransaction.
        where(payment_method_id: wallet.id, payment_method_type: 'wallet').
        where(used_date: Time.zone.now.ago(90.days).strftime('%Y%m%d')..@from.yesterday).
        order(used_date: 'DESC').
        first
    transactions[:next_transaction_used_date] = next_transaction.try(:used_date) ? next_transaction.used_date.strftime('%Y-%m-%d %H:%M:%S') : nil

    # List
    transaction_ids = Entities::UserManuallyCreatedTransaction.
                      where(payment_method_id: wallet.id, payment_method_type: 'wallet').
                      where(used_date: @from..@to).
                      pluck(:id)

    return transactions if transaction_ids.blank?

    transactions[:user_distributed_transaction] = Entities::UserDistributedTransaction.
                                                  joins(:at_transaction_category).
                                                  includes(:at_transaction_category).
                                                  joins(:user_manually_created_transaction).
                                                  includes(:user_manually_created_transaction).
                                                  where(user_manually_created_transaction_id: transaction_ids).
                                                  order(used_date: 'DESC')
    transactions
  end

  def self.save_plus_balance(id, num)
    w = Entities::Wallet.find_by(id: id)
    return if w.blank?
    w.balance = w.balance + num
    w.save!
  end

  def self.save_minus_balance(id, num)
    w = Entities::Wallet.find_by(id: id)
    return if w.blank?
    w.balance = w.balance - num
    w.save!
  end
end
