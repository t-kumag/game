class Services::TransactionService
  def initialize(user, category_version, category_id, share, scope=nil, with_group=false, from, to)
    @user = user
    @category_id = category_id
    @share = share == "true" ? true : false
    @with_group = with_group
    @scope = scope
    @category_version = category_version

    # from の 00:00:00 から to の 23:59:59 までのデータを取得
    # from/to の指定がなければ当月の月初から月末までのデータを取得
    @from = from ? Time.parse(from).beginning_of_day : Time.zone.today.beginning_of_month.beginning_of_day
    @to = to ? Time.parse(to).end_of_day : Time.zone.today.end_of_month.end_of_day
  end

  def list(ids = @category_id)
    shared_accounts = get_shared_account_ids

    # 明細を取得
    transactions = fetch_transactions(ids, @from, @to)

    # 削除された口座の明細を削除
    transactions = remove_delete_account_transaction transactions
    unless @with_group
      transactions = remove_shared_transaction(transactions, shared_accounts)
    end

    # レスポンスの形に成形する
    transactions = generate_response_from_transactions(transactions, shared_accounts)
    # scopeがincomeの場合入金のみにする
    remove_scope_income(transactions)
    # scopeがexpenseの場合出金のみにする
    remove_scope_expence(transactions)
    # used_dateでソート
    sort_by_used_date transactions

  end

  def fetch_transactions(ids, from, to)
    convert_ids = []
    @category_service = Services::CategoryService.new(@category_version)

    condition = {}
    # ユーザーとshareの条件
    if @with_group
      # 家族画面　
      # 自分とパートナーのuser_id、明細のshare:trueで検索
      condition = {user_id: [@user.id, @user.partner_user.id], share: true}
    else
      if @share
        # 個人画面　振り分けた明細を含む
        # 自分のdistribute_user_id、明細のshare:falseで検索
        condition = {distribute_user_id: @user.id, share: false}
      else
        # 個人画面　振り分けた明細を含めない
        # 自分のdistribute_user_id＋自分のuser_idでshare:trueで検索
        condition = {distribute_user_id: @user.id, share: false}
      end
    end

    # カテゴリの条件
    if ids.present? && @category_service.is_latest_version?
      condition.merge(at_transaction_category_id: ids)
    elsif ids.present?
      undefined_category = @category_service.get_undefined_transaction_category(@category_version)
      undefined_id = undefined_category[0].to_h['id']
      if ids.try(:include?, undefined_id)
        ids << nil
      end
      condition.merge(at_transaction_categories: {before_version_id: ids})
    end

    # 期間の条件
    condition.merge(used_date: from..to)

    bank_tarnsactions   = Entities::UserDistributedTransaction.joins(:at_user_bank_transaction).includes(:at_user_bank_transaction).joins(:at_transaction_category).where(condition)
    card_transactions   = Entities::UserDistributedTransaction.joins(:at_user_card_transaction).includes(:at_user_card_transaction).joins(:at_transaction_category).where(condition)
    emoney_transactions = Entities::UserDistributedTransaction.joins(:at_user_emoney_transaction).includes(:at_user_emoney_transaction).joins(:at_transaction_category).where(condition)
    user_manually_created_transactions = Entities::UserDistributedTransaction.joins(:user_manually_created_transaction).includes(:user_manually_created_transaction).joins(:at_transaction_category).where(condition)
    bank_tarnsactions + card_transactions + emoney_transactions + user_manually_created_transactions
  end

  def fetch_transactions_old(ids, from, to)
    # カテゴリ ID の指定がなければ全件抽出
    if ids.present?
      convert_ids = []
      @category_service = Services::CategoryService.new(@category_version)

      unless @category_service.is_latest_version?
        undefined_category = @category_service.get_undefined_transaction_category(@category_version)
        undefined_id = undefined_category[0].to_h['id']
        if ids.try(:include?, undefined_id)
          ids << nil
        end
        # 旧バージョンのカテゴリの場合、旧バージョンのbefore_version_idで検索する。
        bank_tarnsactions   = Entities::UserDistributedTransaction.joins(:at_user_bank_transaction).includes(:at_user_bank_transaction).joins(:at_transaction_category).where(user_id: @user.id, used_date: from..to, at_transaction_categories: {before_version_id: ids})
        card_transactions   = Entities::UserDistributedTransaction.joins(:at_user_card_transaction).includes(:at_user_card_transaction).joins(:at_transaction_category).where(user_id: @user.id, used_date: from..to, at_transaction_categories: {before_version_id: ids})
        emoney_transactions = Entities::UserDistributedTransaction.joins(:at_user_emoney_transaction).includes(:at_user_emoney_transaction).joins(:at_transaction_category).where(user_id: @user.id, used_date: from..to, at_transaction_categories: {before_version_id: ids})
        user_manually_created_transactions = Entities::UserDistributedTransaction.joins(:user_manually_created_transaction).includes(:user_manually_created_transaction).joins(:at_transaction_category).where(user_id: @user.id, used_date: from..to, at_transaction_categories: {before_version_id: ids})
      else
        # 最新バージョンのカテゴリの場合、idで検索する。
        bank_tarnsactions   = Entities::UserDistributedTransaction.joins(:at_user_bank_transaction).includes(:at_user_bank_transaction).where(user_id: @user.id, at_transaction_category_id: ids, used_date: from..to)
        card_transactions   = Entities::UserDistributedTransaction.joins(:at_user_card_transaction).includes(:at_user_card_transaction).where(user_id: @user.id, at_transaction_category_id: ids, used_date: from..to)
        emoney_transactions = Entities::UserDistributedTransaction.joins(:at_user_emoney_transaction).includes(:at_user_emoney_transaction).where(user_id: @user.id, at_transaction_category_id: ids, used_date: from..to)
        user_manually_created_transactions = Entities::UserDistributedTransaction.joins(:user_manually_created_transaction).includes(:user_manually_created_transaction).where(user_id: @user.id, at_transaction_category_id: ids, used_date: from..to)
      end
    else
      # カテゴリの指定がない場合、全て取得する。
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
        wallet_id: wallet_id_for_taransaction(t),
        at_transaction_category_id: t.at_transaction_category_id,
        is_shared: t.share,
        is_account_shared: shared_account?(t, shared_accounts),
        is_ignored: t.ignore,
        user_id: t.user_id,
        amount: t.amount,
        used_date: t.used_date,
        used_location: t.used_location,
        memo: t.memo,
        transaction_id: t.at_user_bank_transaction_id || t.at_user_card_transaction_id || t.at_user_emoney_transaction_id || t.user_manually_created_transaction_id,
        type: t.type
      }
    }
    response
  end

  def sort_by_used_date(transactions)
    i = 0
    transactions.sort_by! { |a| [a[:used_date], i += 1] }.reverse!
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
      if @share === true
        if shared_account?(t, shared_accounts)
          # シェアしている口座の明細は削除する
          true
        else
          # シェアしていない口座の明細 or シェアしていない明細は削除しない
          false
        end
      end
    end
  end

  def remove_delete_account_transaction(transactions)
    return {} if transactions.blank?
    delete_bank_account_ids = Entities::AtUserBankAccount.with_deleted.where(at_user_id: @user.try(:at_user).try(:id)).where.not(deleted_at: nil).try(:pluck, :id)
    delete_card_account_ids = Entities::AtUserCardAccount.with_deleted.where(at_user_id: @user.try(:at_user).try(:id)).where.not(deleted_at: nil).try(:pluck, :id)
    delete_emoney_account_ids = Entities::AtUserEmoneyServiceAccount.with_deleted.where(at_user_id: @user.try(:at_user).try(:id)).where.not(deleted_at: nil).try(:pluck, :id)

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
    if @user.try(:at_user).try(:at_user_bank_accounts)
      shared[:bank_account_ids] = @user.at_user.at_user_bank_accounts.where(share: true).pluck(:id)
    end
    if @user.try(:at_user).try(:at_user_card_accounts)
      shared[:card_account_ids] =  @user.at_user.at_user_card_accounts.where(share: true).pluck(:id)
    end
    if @user.try(:at_user).try(:at_user_emoney_service_accounts)
      shared[:emoney_account_ids] = @user.at_user.at_user_emoney_service_accounts.where(share: true).pluck(:id)
    end
    shared
  end

  def wallet_id_for_taransaction(taransaction)
    return nil if taransaction.blank? || taransaction.user_manually_created_transaction.blank?
    ut = taransaction.user_manually_created_transaction
    return nil unless ut.try(:payment_method_type)
    ut.payment_method_id if ut.payment_method_type == "wallet" && ut.payment_method_id
  end

  def self.fetch_tran_type(transactions, distributed_type, user)
    trans = fetch_summary_distributed_type(transactions, user)

    case distributed_type
    when "family" then
      return trans[:family]
    when "owner" then
      return trans[:owner]
    when "partner" then
      return trans[:partner]
    end
  end

  def self.fetch_summary_distributed_type(transactions, user)
    response = set_response
    transactions.each do |t|
      if t[:is_account_shared] && t[:is_shared]
        response[:family] << t
      elsif t[:is_shared] == true && t[:is_account_shared] == false && t[:user_id] == user.id
        response[:owner] << t
      elsif t[:is_shared] == true && t[:is_account_shared] == false && t[:user_id] != user.id
        response[:partner] << t
      end
    end
    response
  end

  def self.fetch_owner_partner_diff_amount(summary)
    diff_amount = summary[:owner][:amount].abs - summary[:partner][:amount].abs
    diff_amount.abs
  end

  def self.fetch_total_amount(summary)
    summary[:family][:amount] + summary[:owner][:amount] + summary[:partner][:amount]
  end

  # ①計算した数値を全て四捨五入
  # ②最大値を除く、合計値を取得
  # ③合計値 - 100で最大値を再取得
  #  => 四捨五入すると全ての値の合計が99だったり、101という結果になることを防ぐため
  # ④該当の変数に最大値を再代入する

  # 例)
  # 1. 下記割合と仮定する
  # 家族 95.3%
  # 個人 3.5%
  # パートナー 1.2%

  # 2. 四捨五入した値
  # 家族 95%
  # 個人 4%
  # パートナー 1%

  # 3. 最大値を除く合計値
  # 4 + 1 = 5
  # なので
  # 100 - 5で家族に95を代入する
  # よって下記割合となる。

  # 家族 95%
  # 個人 4%
  # パートナー 1%
  def self.fetch_tran_rate(summary)
    # それぞれの率の値をhash値にする
    summary_rate = {family: summary[:family][:rate], owner: summary[:owner][:rate], partner: summary[:partner][:rate]}

    # 家族率、個人率、パートナー率の中で最大値取得
    max_rate = summary_rate.max{ |x, y| x[1] <=> y[1] }

    # 数値を四捨五入することによって合計割合が100にならないケースが存在した場合、最大値で調整する
    Hash[*max_rate].map { |key, _|
      summary_rate.delete(key)
      summary[key][:rate] = 100 - summary_rate.values.inject(:+)
    }
    summary
  end

  def self.fetch_detail(taransactions, total_amount)

    summary = {}

    taransactions.each do |key, detail|
      summary[key] = {}
      summary[key][:rate] = 0
      summary[key][:amount] = 0
      summary[key][:count] = 0

      next if total_amount.to_i.zero?

      detail.each_with_index do |tr, i|
        key_amount = summary[key][:amount] += tr[:amount]
        summary[key] = {
            count: i + 1,
            amount: key_amount,
            rate: calculate_percent(key_amount, total_amount)
        }
      end
    end

    summary = fetch_tran_rate(summary) unless total_amount.to_i.zero?
    summary[:owner_partner_diff_amount] = fetch_owner_partner_diff_amount(summary)
    summary[:total_amount] = fetch_total_amount(summary)
    summary
  end

  private
  def self.calculate_percent(transaction_amount, total_amount)
    (transaction_amount.to_f / total_amount.to_f * 100).round
  end

  def self.set_response
    response = {}
    response[:family] = []
    response[:owner] = []
    response[:partner] = []
    response
  end

end
