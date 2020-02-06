# 各金融のモデルが特定できない場合に利用する
# モデルが特定できる場合はEntities::Financeを参照する
# サンプルケース：fnc_idは特定できるが対象のモデルが特定できない場合
class Services::FinanceService
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def find_finance(key, val)
    f = Entities::AtUserBankAccount.find_by(at_user_id: user.at_user.id, key => val)
    return f if f.present?
    f = Entities::AtUserCardAccount.find_by(at_user_id: user.at_user.id, key => val)
    return f if f.present?
    f = Entities::AtUserEmoneyServiceAccount.find_by(at_user_id: user.at_user.id, key => val)
    return f if f.present?
  end

  # 指定範囲のdailyの残高を計算し保存する
  #  ==Example==
  #
  # 

  def self.save_balance_log(finance, finance_transaction, from=nil)
    finance = Entities::Finance.new(finance)
    finance_transaction = Entities::FinanceTransaction.new(finance_transaction)

    from = Time.zone.today.strftime('%Y-%m-%d') if from.nil?
    to = Time.zone.today.strftime('%Y-%m-%d')

    ft_ids = finance_transaction.model.
      where(finance.relation_key => finance.id).
      where(finance_transaction.date_column => from..to).
      pluck(:id)

#wallet payment_method_type payment_method_id
    # ft_ids = finance_transaction.model.
    #     where(payment_method_id: finance.id).
    #     where(payment_method_type: "wallet").
    #     where(finance_transaction.date_column => from..to).
    #     pluck(:id)
    # return [] if ft_ids.blank?

    dt_rows = Entities::UserDistributedTransaction.
      where(finance_transaction.relation_key => ft_ids).
      where(used_date: from..to).
      order(used_date: :desc)
    return if dt_rows.blank?

    # 日毎の残高を計算
    same_date = ''
    calc_balances = {}
    dt_rows.each do |t|
      if same_date != t.used_date
        same_date = t.used_date
      end

      calc_balances = calc_balances.merge({t.used_date => t.amount}) do |_, old_val, new_val|
        # 同一keyの場合は集計する
        old_val + new_val
      end
    end

  #p calc_balances

    base_balance = finance.balance
    calc_balances.each do |k, _|
      calc_balances[k] += base_balance
      base_balance = calc_balances[k]
    end

  #p calc_balances

    # DB insert用に整形する
    save_balances = []
    latest_date = from
    calc_balances.each_with_index do |(date, balance), i|
      latest_date = date if from < date && latest_date < date # 明細の最終日
      save_balances << {finance.relation_key => finance.id, date: date, balance: balance}

      # 配列の最後は何もしない
      if i == calc_balances.length - 1
        break
      end

      #-1の日がなければは空を代入
      yesterday = date
      31.times do
        yesterday = yesterday.ago(1.days)
        unless calc_balances.has_key?(yesterday)
          save_balances << {finance.relation_key => finance.id, date: yesterday, balance: balance}
        else
          break
        end
      end
    end

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

    #p save_balances

    # 残高ログを登録
    Entities::BalanceLog.import save_balances,
        on_duplicate_key_update: [finance.relation_key, :date, :balance]

    # 残高計算に使用した基準となる残高の値を登録。計算がバグっていた場合のリカバリ用の値
    today_balance_log = Entities::BalanceLog.find_by(finance.relation_key => finance.id, date: to)
    today_balance_log.update!(base_balance: finance.balance)
  end
end