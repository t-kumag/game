# TODO 目標単位でも集計できるようにする
class Services::PlService
  def initialize(user, with_group=false)
    @user = user
    @with_group = with_group
  end
  
  def ignore_at_category_ids
    [
      '1581', # カード返済（クレジットカード引き落とし）
    ]
  end

  def bank_category_summary(share, from=Time.zone.today.beginning_of_month, to=Time.zone.today.end_of_month)
    sql = <<-EOS
      SELECT
        udt.at_transaction_category_id,
        udt.at_user_bank_transaction_id,
        aubt.at_user_bank_account_id,
      CASE
        WHEN udt.amount > 0 THEN udt.amount
        ELSE 0
      END AS amount_receipt,
      CASE
        WHEN udt.amount < 0 THEN udt.amount
        ELSE 0
      END AS amount_payment,
        atc.category_name1,
        atc.category_name2
      FROM
        user_distributed_transactions as udt
      INNER JOIN
        at_user_bank_transactions as aubt
      ON
        aubt.id = udt.at_user_bank_transaction_id
      INNER JOIN
        at_user_bank_accounts as auba
      ON
        auba.id = aubt.at_user_bank_account_id
      INNER JOIN
        at_transaction_categories as atc
      ON
        udt.at_transaction_category_id = atc.id
      WHERE
        udt.user_id in (#{user_ids.join(',')})
      AND
        #{sql_shared("auba", share)}
      AND
        atc.at_category_id not in (#{ignore_at_category_ids.join(',')})
      AND
        udt.used_date >= "#{from}"
      AND
        udt.used_date <= "#{to}"
      AND
        auba.deleted_at IS NULL
    EOS

    ActiveRecord::Base.connection.select_all(sql).to_hash
  end

  def card_category_summary(share, from=Time.zone.today.beginning_of_month, to=Time.zone.today.end_of_month)
    sql = <<-EOS
      SELECT
        udt.at_transaction_category_id,
        udt.at_user_card_transaction_id,
        auct.at_user_card_account_id,
      CASE
        WHEN udt.amount < 0 THEN udt.amount
        ELSE 0
      END AS amount_payment,
        atc.category_name1,
        atc.category_name2
      FROM
        user_distributed_transactions as udt
      INNER JOIN
        at_user_card_transactions as auct
      ON
        auct.id = udt.at_user_card_transaction_id
      INNER JOIN
        at_user_card_accounts as auca
      ON
        auca.id = auct.at_user_card_account_id
      INNER JOIN
        at_transaction_categories as atc
      ON
        udt.at_transaction_category_id = atc.id
      WHERE
        udt.user_id in (#{user_ids.join(',')})
      AND
        #{sql_shared("auca", share)}
      AND
        atc.at_category_id not in (#{ignore_at_category_ids.join(',')})
      AND
        udt.used_date >= "#{from}"
      AND
        udt.used_date <= "#{to}"
      AND
        auca.deleted_at IS NULL
    EOS

    ActiveRecord::Base.connection.select_all(sql).to_hash
  end

  def emoney_category_summary(share, from=Time.zone.today.beginning_of_month, to=Time.zone.today.end_of_month)
    sql = <<-EOS
      SELECT
        udt.at_transaction_category_id,
        udt.at_user_emoney_transaction_id,
        auet.at_user_emoney_service_account_id,
      CASE
        WHEN udt.amount > 0 THEN udt.amount
        ELSE 0
      END AS amount_receipt,
      CASE
        WHEN udt.amount < 0 THEN udt.amount
        ELSE 0
      END AS amount_payment,
        atc.category_name1,
        atc.category_name2
      FROM
        user_distributed_transactions as udt
      INNER JOIN
        at_user_emoney_transactions as auet
      ON
        auet.id = udt.at_user_emoney_transaction_id
      INNER JOIN
        at_user_emoney_service_accounts as auea
      ON
        auea.id = auet.at_user_emoney_service_account_id
      INNER JOIN
        at_transaction_categories as atc
      ON
        udt.at_transaction_category_id = atc.id
      WHERE
        udt.user_id in (#{user_ids.join(',')})
      AND
        #{sql_shared("auea", share)}
      AND
        atc.at_category_id not in (#{ignore_at_category_ids.join(',')})
      AND
        udt.used_date >= "#{from}"
      AND
        udt.used_date <= "#{to}"
      AND
        auea.deleted_at IS NULL
    EOS

    ActiveRecord::Base.connection.select_all(sql).to_hash
  end

  def user_manually_created_category_summary(share, from=Time.zone.today.beginning_of_month, to=Time.zone.today.end_of_month)
    sql = <<-EOS
      SELECT
        udt.at_transaction_category_id,
      CASE
        WHEN udt.amount < 0 THEN udt.amount
        ELSE 0
      END AS amount_payment,
      CASE
        WHEN udt.amount > 0 THEN udt.amount
        ELSE 0
      END AS amount_receipt,
        atc.category_name1,
        atc.category_name2
      FROM
        user_distributed_transactions as udt
      INNER JOIN
        user_manually_created_transactions as umct
      ON
        umct.id = udt.user_manually_created_transaction_id
      INNER JOIN
        at_transaction_categories as atc
      ON
        udt.at_transaction_category_id = atc.id
      WHERE
        udt.user_id in (#{user_ids.join(',')})
      AND
        udt.share in (#{share.join(',')})
      AND
        udt.used_date >= "#{from}"
      AND
        udt.used_date <= "#{to}"
    EOS

    ActiveRecord::Base.connection.select_all(sql).to_hash
  end

  def sql_shared(account, share)
    if @with_group
      # 家族 シェアしている口座 or シェアしている明細
      <<-EOS
        (#{account}.share = 1 OR udt.share = 1)
      EOS
    else
      if share.size > 1
        # 個人 家族ON シェアしていない口座 and 全明細
        <<-EOS
          #{account}.share = 0 AND udt.share in (0, 1)
        EOS
      else
        # 個人 家族OFF シェアしていない口座 and シェアしていない明細
        <<-EOS
          #{account}.share = 0 AND udt.share = 0
        EOS
      end
    end
  end

  def user_ids
    user_ids = [@user.id]
    if @with_group && @user.try(:partner_user).try(:id)
      return user_ids << @user.partner_user.id
    end
    user_ids
  end

  def at_user_ids
    at_user_ids = @user.try(:at_user).try(:id) ? [@user.at_user.id] : []
    if @with_group && @user.try(:partner_user).try(:at_user).try(:id)
      return at_user_ids << @user.partner_user.at_user.id
    end
    at_user_ids
  end

  def pl_category_summary(share, from, to)
    from = from || Time.zone.today.beginning_of_month
    to = to || Time.zone.today.end_of_month

    # P/L 用の明細を取得
    pl_bank = bank_category_summary(share, from, to)
    pl_card = card_category_summary(share, from, to)
    pl_emoney = emoney_category_summary(share, from, to)

    pl_bank = remove_debit_transactions(pl_bank, pl_card)

    pl_bank = group_by_category_id(pl_bank)
    pl_card = group_by_category_id(pl_card)
    pl_emoney = group_by_category_id(pl_emoney)

    pl_user_manually_created = user_manually_created_category_summary(share, from, to)
    merge_category_summary(pl_user_manually_created, merge_category_summary(pl_emoney, merge_category_summary(pl_card, pl_bank)))
  end

  def pl_summary(share, from=Time.zone.today.beginning_of_month, to=Time.zone.today.end_of_month)
    from = from || Time.zone.today.beginning_of_month
    to = to || Time.zone.today.end_of_month

    pl_category_summary = pl_category_summary(share, from, to)
    pl_summaries = {
        income_amount: 0,
        expense_amount: 0
    }
    pl_category_summary.each do |summary|
      summary['amount_receipt'] ||= 0
      summary['amount_payment'] ||= 0
      pl_summaries[:income_amount] += summary['amount_receipt']
      pl_summaries[:expense_amount] += summary['amount_payment']
    end
    pl_summaries
  end

  def remove_duplicated_transaction(transactions)
    ignore_at_category_ids = [
      '1581', # カード返済（クレジットカード引き落とし）
      '1699', # その他入金（電子マネーへのチャージ電子マネー側入金）
      '1799', # その他出金（電子マネーへのチャージ銀行側出金）
    ]
    ignore_at_transaction_category_ids = Entities::AtTransactionCategory.where(at_category_id: ignore_at_category_ids).pluck(:id)
    transactions.reject do |t|
      ignore_at_transaction_category_ids.include? t['at_transaction_category_id']
    end
  end

  def group_by_category_id(pl)
    after_summaries = []
    pl.each do |v|
      next if v['at_transaction_category_id'].blank?
      # after_summaries から同カテゴリのアイテムを抽出
      summary = after_summaries.select do |t|
        v['at_transaction_category_id'] === t['at_transaction_category_id']
      end.first

      v['amount_receipt'] ||= 0
      v['amount_payment'] ||= 0

       # after_summaries に同カテゴリのアイテムがなければ after_summaries に追加し、あれば額のみ足し込み
       if summary.blank?
        after_summaries << {
          at_transaction_category_id: v['at_transaction_category_id'],
          category_name1: v['category_name1'],
          category_name2: v['category_name2'],
          amount_receipt: v['amount_receipt'],
          amount_payment: v['amount_payment']
        }.stringify_keys
      else
        idx = after_summaries.find_index(summary)
        summary['amount_receipt'] ||= 0
        summary['amount_payment'] ||= 0
        after_summaries[idx] = {
          at_transaction_category_id: v['at_transaction_category_id'],
          category_name1: v['category_name1'],
          category_name2: v['category_name2'],
          amount_receipt: v['amount_receipt'] + summary['amount_receipt'],
          amount_payment: v['amount_payment'] + summary['amount_payment']
        }.stringify_keys
      end
    end
    after_summaries
  end

  def merge_category_summary(pl, before_summaries)
    after_summaries = before_summaries.dup
    unless pl.blank? && after_summaries.blank?
      pl.each do |v|
        next if v['at_transaction_category_id'].blank?
        # after_summaries から同カテゴリのアイテムを抽出
        summary = after_summaries.select {|category_summary|
          next if category_summary.blank? || category_summary['at_transaction_category_id'].blank?
          category_summary['at_transaction_category_id'] == v['at_transaction_category_id']
        }.first
        v['amount_receipt'] ||= 0
        v['amount_payment'] ||= 0

        # after_summaries に同カテゴリのアイテムがなければ after_summaries に追加し、あれば額のみ足し込み
        if summary.blank?
          after_summaries << v
        else
          idx = after_summaries.find_index(summary)
          v['amount_receipt'] ||= 0
          summary['amount_receipt'] ||= 0
          summary['amount_payment'] ||= 0
          after_summaries[idx] = {
            at_transaction_category_id: v['at_transaction_category_id'],
            category_name1: v['category_name1'],
            category_name2: v['category_name2'],
            amount_receipt: v['amount_receipt'] + summary['amount_receipt'],
            amount_payment: v['amount_payment'] + summary['amount_payment']
          }.stringify_keys
        end
      end
    end
    after_summaries.compact! unless after_summaries.blank?

    after_summaries
  end

  def pl_grouped_category_summary(share, from, to)
    from = from || Time.zone.today.beginning_of_month
    to = to || Time.zone.today.end_of_month

    # PL を大項目ごとに集計し直すため、大項目の一覧を取得
    grouped_categories = Entities::AtGroupedCategory.all.map { |category|
      {
        id: category.id,
        name: category.category_name,
      }
    }
    summary = []
    # 小項目ごとの PL 集計結果から、大項目ごとに再集計を行う
    pl_category_summary(share, from, to).each { |item|
      # category_name1　が有効なら
      matched_category = grouped_categories.find { |category| category[:name] === item['category_name1'] }
      if (matched_category.present?)
          index = summary.index{ |s| s['at_transaction_category_id'] === matched_category[:id] }
          if (index.nil?)
            summary << {
              'at_transaction_category_id' => matched_category[:id],
              'category_name1' => matched_category[:name],
              'category_name2' => nil,
              'amount_receipt' => 0,
              'amount_payment' => 0,
            }
            index = summary.size - 1
          end
        summary[index]['amount_receipt'] += item['amount_receipt']
        summary[index]['amount_payment'] += item['amount_payment']
      end
    }
    summary.sort { |a, b| a['at_transaction_category_id'] <=> b['at_transaction_category_id'] }
  end

  private
  
  def remove_debit_transactions(pl_bank, pl_card)
    # デビットの明細リスト
    debit_transactions = debit_transactions(pl_bank, pl_card)
    # デビットの明細IDリスト
    debit_transactions_ids = debit_transactions.pluck(:id)
    # デビットの消込
    pl_bank.reject do |t|
      debit_transactions_ids.include? t['at_user_bank_transaction_id']
    end
  end

  def debit_transactions(pl_bank, pl_card)
    debit_transactions = []
    bank_ids = pl_bank.pluck("at_user_bank_account_id").uniq
    card_ids = pl_card.pluck("at_user_card_account_id").uniq
    debit_card = debit_card(card_ids)

    debit_card.each do |debit_card_id|
      bank_ids.each do |bank_id|
        debit_card = Entities::AtUserCardAccount.find_by(id: debit_card_id, at_user_id: at_user_ids)
        bank = Entities::AtUserBankAccount.find_by(id: bank_id, at_user_id: at_user_ids)
        next unless debit_card.try(:at_user_card_transactions)
        debit_card.at_user_card_transactions.each do |card_transaction|
          bank.at_user_bank_transactions.each do |bank_transaction|
            debit_transactions << bank_transaction if check_trade_date_and_amount(bank_transaction, card_transaction)
          end
        end
      end
    end

    debit_transactions
  end

  def debit_card(card_ids)
    card_ids.reject do |card_id|
      card = Entities::AtUserCardAccount.find_by(id: card_id, at_user_id: at_user_ids)
      next unless card.present?
      if card.fnc_nm.include?("デビット") || card.fnc_nm.include?("ﾃﾞﾋﾞｯﾄ")
        false
      else
        true
      end
    end
  end

  def check_trade_date_and_amount(bank_transaction, card_transaction)
    # カード明細の取引日と銀行明細の取引日が同日
    # 且つカード明細の支払い金額と銀行明細の支払い金額が同額
    if bank_transaction.trade_date.strftime("%Y-%m-%d") === card_transaction.used_date.strftime("%Y-%m-%d") &&
      bank_transaction.amount_payment === card_transaction.amount
      true
    else
      false
    end
  end

end