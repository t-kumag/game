# TODO 目標単位でも集計できるようにする
class Services::PlService
  def initialize(user, with_group=false)
    @user = user
    @with_group = with_group
  end

  def bank_category_summary(share, from=Time.zone.today.beginning_of_month, to=Time.zone.today.end_of_month)
    sql = <<-EOS
      SELECT
        udt.at_transaction_category_id,
        sum(aubt.amount_receipt) as amount_receipt,
        sum(aubt.amount_payment) as amount_payment,
        atc.category_name1,
        atc.category_name2
      FROM
        user_distributed_transactions as udt
      INNER JOIN
        at_user_bank_transactions as aubt
      ON
        aubt.id = udt.at_user_bank_transaction_id
      INNER JOIN
        at_transaction_categories as atc
      ON
        udt.at_transaction_category_id = atc.id
      WHERE
        #{sql_user_or_group}
      AND
        udt.share in (#{share.join(',')})
      AND
        udt.used_date >= "#{from}"
      AND
        udt.used_date <= "#{to}"
      GROUP BY
        udt.at_transaction_category_id
    EOS

    ActiveRecord::Base.connection.select_all(sql).to_hash
  end

  def card_category_summary(share, from=Time.zone.today.beginning_of_month, to=Time.zone.today.end_of_month)
    sql = <<-EOS
      SELECT
        udt.at_transaction_category_id,
        sum(auct.amount) as amount_payment,
        atc.category_name1,
        atc.category_name2
      FROM
        user_distributed_transactions as udt
      INNER JOIN
        at_user_card_transactions as auct
      ON
        auct.id = udt.at_user_card_transaction_id
      INNER JOIN
        at_transaction_categories as atc
      ON
        udt.at_transaction_category_id = atc.id
      WHERE
        #{sql_user_or_group}
      AND
        udt.share in (#{share.join(',')})
      AND
        udt.used_date >= "#{from}"
      AND
        udt.used_date <= "#{to}"
      GROUP BY
        udt.at_transaction_category_id
    EOS

    ActiveRecord::Base.connection.select_all(sql).to_hash
  end

  def emoney_category_summary(share, from=Time.zone.today.beginning_of_month, to=Time.zone.today.end_of_month)
    sql = <<-EOS
      SELECT
        udt.at_transaction_category_id,
        sum(auet.amount_receipt) as amount_receipt,
        sum(auet.amount_payment) as amount_payment,
        atc.category_name1,
        atc.category_name2
      FROM
        user_distributed_transactions as udt
      INNER JOIN
        at_user_emoney_transactions as auet
      ON
        auet.id = udt.at_user_emoney_transaction_id
      INNER JOIN
        at_transaction_categories as atc
      ON
        udt.at_transaction_category_id = atc.id
      WHERE
        #{sql_user_or_group}
      AND
        udt.share in (#{share.join(',')})
      AND
        udt.used_date >= "#{from}"
      AND
        udt.used_date <= "#{to}"
      GROUP BY
        udt.at_transaction_category_id
    EOS

    ActiveRecord::Base.connection.select_all(sql).to_hash
  end

  def user_manually_created_category_summary(share, from=Time.zone.today.beginning_of_month, to=Time.zone.today.end_of_month)
    sql = <<-EOS
      SELECT
        udt.at_transaction_category_id,
        sum(umct.amount) as amount_payment,
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
        #{sql_user_or_group}
      AND
        udt.share in (#{share.join(',')})
      AND
        udt.used_date >= "#{from}"
      AND
        udt.used_date <= "#{to}"
      GROUP BY
        udt.at_transaction_category_id
    EOS

    ActiveRecord::Base.connection.select_all(sql).to_hash
  end

  def sql_user_or_group
    if @with_group && @user.group_id.size > 1
      <<-EOS
        udt.group_id = #{@user.group_id}
      EOS
    else
      <<-EOS
        udt.user_id = #{@user.id}
      EOS
    end
  end

  def pl_category_summary(share, from, to)
    from = from || Time.zone.today.beginning_of_month
    to = to || Time.zone.today.end_of_month

    # P/L 用の明細を取得
    pl_bank = bank_category_summary(share, from, to)
    pl_card = card_category_summary(share, from, to)
    pl_emoney = emoney_category_summary(share, from, to)

    #　P/L の計算から指定カテゴリを排除する
    pl_bank = remove_duplicated_transaction(pl_bank)
    pl_card = remove_duplicated_transaction(pl_card)
    pl_emoney = remove_duplicated_transaction(pl_emoney)

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

        # after_summaries に同カテゴリのアイテムがなければ即 INSERT し、あれば額のみ足し込み
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

end
