class Services::AtBankTransactionService

  def initialize(user, is_group=false, from=nil, to=nil)
    @user = user
    @is_group = is_group
    @from = from ? Time.parse(from).beginning_of_day : Time.zone.today.beginning_of_month.beginning_of_day
    @to = to ? Time.parse(to).end_of_day : Time.zone.today.end_of_month.end_of_day
  end

  def list(account_id)
    distributed_transactions = get_distributed_transactions(account_id)
    return {} if distributed_transactions[:user_distributed_transaction].blank?

    distributed_transactions
  end

  def detail(account_id, transaction_id)
    distributed = get_distributed_transaction(account_id, transaction_id)
    return {} if distributed.blank?
    {
      amount: distributed[:user_distributed_transaction].amount,
      at_transaction_category_id: distributed[:user_distributed_transaction].at_transaction_category_id,
      category_name1: distributed[:user_distributed_transaction].at_transaction_category.category_name1,
      category_name2: distributed[:user_distributed_transaction].at_transaction_category.category_name2,
      used_date: distributed[:user_distributed_transaction].at_user_bank_transaction.trade_date,
      used_location: distributed[:user_distributed_transaction].used_location,
      user_id: distributed[:user_distributed_transaction].user_id,
      is_account_shared: distributed[:is_account_shared],
      is_shared: distributed[:user_distributed_transaction].at_user_bank_transaction.at_user_bank_account.share || distributed[:user_distributed_transaction].share,
      payment_name: distributed[:user_distributed_transaction].at_user_bank_transaction.at_user_bank_account.fnc_nm + distributed[:user_distributed_transaction].at_user_bank_transaction.at_user_bank_account.brn_nm,
      transaction_id: distributed[:user_distributed_transaction].at_user_bank_transaction_id,
    }
  end

  def update(account_id, transaction_id, category_id, used_location, is_shared, group_id)
    distributed = get_distributed_transaction(account_id, transaction_id)
    return {} if distributed[:user_distributed_transaction].blank?

    distributed[:user_distributed_transaction].at_transaction_category_id = category_id
    distributed[:user_distributed_transaction].used_location = used_location
    distributed[:user_distributed_transaction].group_id = group_id
    distributed[:user_distributed_transaction].share = is_shared
    distributed[:user_distributed_transaction].save!
  end

  def get_distributed_transaction(account_id, transaction_id)
    transaction = {}
    if @is_group === true
      bank = Entities::AtUserBankAccount.find_by(id: account_id, at_user_id: [@user.try(:at_user).try(:id), @user.partner_user.try(:at_user).try(:id)])
    else
      bank = Entities::AtUserBankAccount.find_by(id: account_id, at_user_id: @user.at_user.id, share: false)
    end
    return {} if bank.blank?

    at_user_bank_transaction = Entities::AtUserBankTransaction.find_by(id: transaction_id, at_user_bank_account_id: bank.id)
    return {} if transaction_id.blank?

    transaction[:is_account_shared] = bank.share
    transaction[:user_distributed_transaction] =  Entities::UserDistributedTransaction
                                                      .joins(:at_transaction_category)
                                                      .includes(:at_transaction_category)
                                                      .find_by(at_user_bank_transaction_id: at_user_bank_transaction.id)
    transaction

    # TODO: BS PL 利用明細から参照されるため、参照元に合わせて処理する必要がある。
    # distributed = Entities::UserDistributedTransaction.find_by(at_user_bank_transaction_id: transaction.id) unless @is_group === true
    # if bank.share === true
    #   distributed = transaction.user_distributed_transaction
    # else
    #   distributed = Entities::UserDistributedTransaction.find_by(at_user_bank_transaction_id: transaction.id)
    # end
    # distributed
  end

  # TODO: リファクタする @user.try(:at_user).try(:id), @user.partner_user.try(:at_user).try(:id)])
  # TODO: nil検索しない
  def get_distributed_transactions(account_id)
    transactions = {}
    if @is_group === true
      bank = Entities::AtUserBankAccount.find_by(id: account_id, at_user_id: [@user.try(:at_user).try(:id), @user.partner_user.try(:at_user).try(:id)])
    else
      bank = Entities::AtUserBankAccount.find_by(id: account_id, at_user_id: @user.at_user.id, share: false)
    end
    return {} if bank.blank?

    transactions[:is_account_shared] = bank.share
    transaction_ids = bank.at_user_bank_transactions.where(trade_date: @from..@to).pluck(:id)

    at_sync_transaction_monthly_logs = Services::AtSyncTransactionMonthlyDateLogService
                                           .latest_transaction_monthly_date(account_id, @to, "at_user_bank_account")
    prev_transaction = nil
    at_sync_transaction_monthly_logs.each do |astml|
      if astml < @from
        prev_from_transaction_date = @from.beginning_of_month.beginning_of_day
        minus_one_sencod_before_from = @from - 1
        prev_transaction = bank.at_user_bank_transactions.order(trade_date: :desc).where(trade_date: prev_from_transaction_date..minus_one_sencod_before_from).first
        break if prev_transaction.present?
      end
    end

    transactions[:prev_from_date] = prev_transaction.try(:trade_date)

    return {} if transaction_ids.blank?
    transactions[:user_distributed_transaction] = Entities::UserDistributedTransaction
                                                      .joins(:at_transaction_category)
                                                      .includes(:at_transaction_category)
                                                      .where(at_user_bank_transaction_id: transaction_ids)
                                                      .order(used_date: "DESC")


    transactions

    # TODO:動作確認問題なければこの処理を削除
    # transaction_ids = bank.at_user_bank_transactions.pluck(:id)
    # return {} if transaction_ids.blank?
    #
    # if @is_group === true
    #   if bank.share === true
    #     distributed_transactions = Entities::UserDistributedTransaction.where(at_user_bank_transaction_id: transaction_ids)
    #                                    .order(used_date: "DESC")
    #                                    .page(page)
    #   else
    #     distributed_transactions = Entities::UserDistributedTransaction.where(at_user_bank_transaction_id: transaction_ids, share: true)
    #                                    .order(used_date: "DESC")
    #                                    .page(page)
    #   end
    # else
    #   distributed_transactions = Entities::UserDistributedTransaction.where(at_user_bank_transaction_id: transaction_ids, share: false)
    #                                  .order(used_date: "DESC")
    #                                  .page(page)
    # end
    # distributed_transactions
  end
end
