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
  #  Services::FinanceService.save_balance(
  #    Entities::Finance.new(Entities::AtUserBankAccount,28),
  #    Entities::FinanceTransaction.new(Entities::AtUserBankTransaction),
  #   '2019-09-01', '2019-12-01')
  def self.save_balance(finance, finance_transaction, from=nil)
    from = Time.zone.today.strftime('%Y-%m-%d') if from.nil?
    to = Time.zone.today.strftime('%Y-%m-%d')

    ft_ids = finance_transaction.base.
      where(finance.relation_key => finance.id).
      where(finance_transaction.date_column => from..to).
      pluck(:id)
    return [] if ft_ids.blank?

    dt_rows = Entities::UserDistributedTransaction.
      where(finance_transaction.relation_key => ft_ids).
      where(used_date: from..to).
      order(used_date: :desc)
    return if dt_rows.blank?

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

    base_balance = finance.balance
    calc_balances.each do |k, _|
      calc_balances[k] += base_balance
      base_balance = calc_balances[k]
    end

    p calc_balances

    save_balances = []
    calc_balances.each_with_index do |(date, amount), i|
      save_balances << {finance.relation_key => finance.id, date: date, amount: amount}

      # 配列の最後は何もしない
      if i == calc_balances.length - 1
        break
      end

      #-1の日がなければは空でいれる
      yesterday = date
      31.times do
        yesterday = yesterday.ago(1.days)
        unless calc_balances.has_key?(yesterday)
          save_balances << {finance.relation_key => finance.id, date: yesterday, amount: amount}
        else
          break
        end
      end

    end

#p save_balances

    Entities::BalanceLog.import save_balances,
      on_duplicate_key_update: [finance.relation_key, :date, :amount]
  end
end