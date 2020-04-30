# 各金融のモデルが特定できない場合に利用する
# モデルが特定できる場合はEntities::Financeを参照する
# サンプルケース：fnc_idは特定できるが対象のモデルが特定できない場合
class Services::FinanceService
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def find_finance(key, val)
    return nil if user.at_user.blank?

    f = Entities::AtUserBankAccount.find_by(at_user_id: user.at_user.id, key => val)
    return f if f.present?
    f = Entities::AtUserCardAccount.find_by(at_user_id: user.at_user.id, key => val)
    return f if f.present?
    f = Entities::AtUserEmoneyServiceAccount.find_by(at_user_id: user.at_user.id, key => val)
    return f if f.present?
    f = Entities::AtUserStockAccount.find_by(at_user_id: user.at_user.id, key => val)
    return f if f.present?
  end

  # 指定範囲のdailyの残高を計算し保存する
  def self.save_balance_log(finance, finance_transaction, from=nil, payment_method_type='')
    finance = Entities::Finance.new(finance)
    finance_transaction = Entities::FinanceTransaction.new(finance_transaction)

    from = Time.zone.today.strftime('%Y-%m-%d') if from.nil?
    to = Time.zone.today.strftime('%Y-%m-%d')

    # 当日の残高を取得、当日データがなければ保存する
    base_balance = finance.balance
    today_balance_log = Entities::BalanceLog.find_by(finance.relation_key => finance.id, date: to)
    Entities::BalanceLog.create!(finance.relation_key => finance.id, date: to, balance: base_balance, base_balance: base_balance) if today_balance_log.blank?

    # 明細取得
    ft_ids = self.finance_transaction_ids(finance, finance_transaction, payment_method_type, from, to)
    return if ft_ids.blank?

    dt_rows = Entities::UserDistributedTransaction.
      where(finance_transaction.relation_key => ft_ids).
      where(used_date: from..to).
      order(used_date: :desc)
    return if dt_rows.blank?

    # 日毎の残高を計算
    same_date = ''
    calc_balances = {}
    dt_rows.each do |t|
      date = t.used_date.since(1.days) # 当日の残高は明細金額を引いたあとの値なので1日後に設定
      if same_date != date
        same_date = date
      end

      calc_balances = calc_balances.merge({date => t.amount}) do |_, old_val, new_val|
        # 同一keyの場合は集計する
        old_val + new_val
      end
    end

    # 日毎の残高を計算
    calc_balances.each do |k, _|
      calc_balances[k] = base_balance - calc_balances[k]
      base_balance = calc_balances[k]
    end

    # 1日後にしていた日にちを元に戻す
    format_calc_balances = {}
    calc_balances.each do |k, v|
      format_calc_balances[k.ago(1.days)] = v
    end

    # DB登録する変数のデータ構造の確認はcalc_balancesとformat_calc_balancesを出力する
    # DB insert用に整形する
    save_balances = []
    latest_date = from
    format_calc_balances.each_with_index do |(date, balance), i|
      latest_date = date if from < date && latest_date < date # 明細の最終日

      save_balances << {finance.relation_key => finance.id, date: date, balance: balance}

      # 配列の最後は後続の処理をスキップ
      if i == format_calc_balances.length - 1
        break
      end

      # 明細がない期間の残高を埋める処理
      yesterday = date
      Settings.at_sync_transaction_max_days.times do
        yesterday = yesterday.ago(1.days)
        unless format_calc_balances.has_key?(yesterday)
          save_balances << {finance.relation_key => finance.id, date: yesterday, balance: balance}
        else
          break
        end
      end
    end

    # p save_balances

    # 当日〜最新の明細がある日までを計算する
    diff_date_num = 0 # 残高計算日と明細の存在する最終日との差分の日にちをカウント
    if latest_date != from
      diff_date_num = (Date.parse(to) - Date.parse(latest_date.strftime('%Y-%m-%d'))).to_i
    end

    none_transaction_date = Time.zone.today.strftime('%Y-%m-%d')
    if diff_date_num > 0
      diff_date_num.to_i.times do |index|
        num = index+1
        save_balances << {finance.relation_key => finance.id, date: none_transaction_date, balance: finance.balance}
        none_transaction_date = Time.zone.today.ago(num.days).strftime('%Y-%m-%d')
      end
    end

    # p save_balances

    # 残高ログを登録
    Entities::BalanceLog.import save_balances,
        on_duplicate_key_update: [finance.relation_key, :date, :balance]

    # 残高計算に使用した基準となる残高の値を登録。計算がバグっていた場合のリカバリ用の値
    today_balance_log = Entities::BalanceLog.find_by(finance.relation_key => finance.id, date: to)
    today_balance_log.update!(base_balance: finance.balance)
  end

  # 自分とパートナーの削除されていない口座のIDを取得
  def all_account_ids(with_group=false)
    account_ids = {bank:[], card:[], emoney:[], wallet:[]}

    if @user.at_user.present?
      Entities::AtUserBankAccount.where(at_user_id: @user.at_user.id).find_each do |ba|
        account_ids[:bank] << ba.id
      end

      Entities::AtUserCardAccount.where(at_user_id: @user.at_user.id).find_each do |ca|
        account_ids[:card] << ca.id
      end

      Entities::AtUserEmoneyServiceAccount.where(at_user_id: @user.at_user.id).find_each do |ea|
        account_ids[:emoney] << ea.id
      end

      Entities::Wallet.where(user_id: @user.id).find_each do |w|
        account_ids[:wallet] << w.id
      end
    end

    if with_group

      return account_ids if @user.partner_user.blank?

      Entities::Wallet.where(user_id: @user.partner_user.id).find_each do |w|
        account_ids[:wallet] << w.id
      end

      return account_ids if @user.partner_user.at_user.blank?

      Entities::AtUserBankAccount.where(at_user_id: @user.partner_user.at_user.id).find_each do |ba|
        account_ids[:bank] << ba.id
      end

      Entities::AtUserCardAccount.where(at_user_id: @user.partner_user.at_user.id).find_each do |ca|
        account_ids[:card] << ca.id
      end

      Entities::AtUserEmoneyServiceAccount.where(at_user_id: @user.partner_user.at_user.id).find_each do |ea|
        account_ids[:emoney] << ea.id
      end
    end
    account_ids
  end

  def get_account(finance)
    finance.where(at_user_id: [@user.at_user, @user.partner_user.try(:at_user)], share: true)
  end

  def update_account(at_user_accounts, params)
    ActiveRecord::Base.transaction do
      before_share = at_user_accounts.share
      after_share = params[:share]
      at_user_accounts.update!(params)

      if (before_share ！= after_share)
        if ("Entities::AtUserBankAccount" == at_user_accounts.class.name)
          transactions = Entities::AtUserBankTransaction.where(at_user_bank_account_id: at_user_accounts.id)
          user_distributed_transactions = Entities::UserDistributedTransaction.where(at_user_bank_transaction_id: transactions.pluck(:id))
        elsif ("Entities::AtUserCardAccount" == at_user_accounts.class.name)
          transactions = Entities::AtUserCardTransaction.where(at_user_card_account_id: at_user_accounts.id)
          user_distributed_transactions = Entiteis::UserDistributedTransaction.where(at_user_card_transaction_id: transactions.pluck(:id))
        elsif ("Entities::AtUserEmoneyServiceAccount" == at_user_accounts.class.name)
          transactions = Entities::AtUserEmoneyTransaction.where(at_user_emoney_account_id: at_user_accounts.id)
          user_distributed_transactions = Entities::UserDistributedTransaction.where(at_user_emoney_transaction_id: transactions.pluck(:id))
        end
        distribute_user_id = after_share ? nil : @user.id
        user_distributed_transactions.update_all("share": after_share, "distribute_user_id": distribute_user_id)
      end

    end
    return at_user_accounts
  end

  private

  def self.finance_transaction_ids(finance, finance_transaction, payment_method_type, from, to)
    if payment_method_type.present?
      finance_transaction.model.
        where(payment_method_id: finance.id).
        where(payment_method_type: payment_method_type).
        where(finance_transaction.date_column => from..to).
        pluck(:id)
    else
      finance_transaction.model.
        where(finance.relation_key => finance.id).
        where(finance_transaction.date_column => from..to).
        pluck(:id)
    end
  end

end
