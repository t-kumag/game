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
        udt.user_id = #{@user.id}
      AND
        udt.share in (#{share.join(',')})
      AND
        udt.used_date >= "#{from}"
      AND
        udt.used_date <= "#{to}"
      #{sql_and_group}
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
        udt.user_id = #{@user.id}
      AND
        udt.share in (#{share.join(',')})
      AND
        udt.used_date >= "#{from}"
      AND
        udt.used_date <= "#{to}"
      #{sql_and_group}
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
        udt.user_id = #{@user.id}
      AND
        udt.share in (#{share.join(',')})
      AND
        udt.used_date >= "#{from}"
      AND
        udt.used_date <= "#{to}"
      #{sql_and_group}
      GROUP BY
        udt.at_transaction_category_id
    EOS

    ActiveRecord::Base.connection.select_all(sql).to_hash
  end

  def sql_and_group
    if @with_group && @user.group_id > 1
      <<-EOS
      AND
        udt.group_id = #{@user.group_id}
      EOS
    end
  end

  def pl_category_summery(share, from, to)
    from = from || Time.zone.today.beginning_of_month
    to = to || Time.zone.today.end_of_month

    # P/L 用の明細を取得
    pl_bank = bank_category_summary(share, from, to)
    pl_card = card_category_summary(share, from, to)
    pl_emoney = emoney_category_summary(share, from, to)

    #　P/L の計算から指定カテゴリを排除する
    pl_bank = remove_duplicated_transaction(pl_bank)
    pl_bank = remove_duplicated_transaction(pl_bank)
    pl_bank = remove_duplicated_transaction(pl_bank)

    merge_category_summery(pl_emoney, merge_category_summery(pl_card, pl_bank))
  end

  def pl_summery(share, from=Time.zone.today.beginning_of_month, to=Time.zone.today.end_of_month)
    from = from || Time.zone.today.beginning_of_month
    to = to || Time.zone.today.end_of_month

    pl_category_summery = pl_category_summery(share, from, to)
    pl_summeries = {
        income_amount: 0,
        expense_amount: 0
    }
    pl_category_summery.each do |summery|
      summery['amount_receipt'] ||= 0
      summery['amount_payment'] ||= 0
      pl_summeries[:income_amount] += summery['amount_receipt']
      pl_summeries[:expense_amount] += summery['amount_payment']
    end
    pl_summeries
  end

  def remove_duplicated_transaction(transactions)
    ignore_at_category_ids = [
      '1581', # カード返済（クレジットカード引き落とし）
      '1699', # その他入金（電子マネーへのチャージ電子マネー側入金）
      '1799', # その他出金（電子マネーへのチャージ銀行側出金）
    ]
    ignore_at_transaction_category_ids = Entities::AtTransactionCategory.where(at_category_id: ignore_at_category_ids).pluck(:id)
    Rails.logger.debug ignore_at_transaction_category_ids 
    transactions.reject do |t|
      ignore_at_transaction_category_ids.include? t['at_transaction_category_id']
    end
  end

  def ignore_category?(category_id)
  end

  def merge_category_summery(pl, before_summeries)
    after_summeries = before_summeries.dup
    unless pl.blank? && after_summeries.blank?
      pl.each do |v|
        next if v['at_transaction_category_id'].blank?
        # after_summeries から同カテゴリのアイテムを抽出
        summery = after_summeries.select {|category_summery|
          next if category_summery.blank? || category_summery['at_transaction_category_id'].blank?
          category_summery['at_transaction_category_id'] == v['at_transaction_category_id']
        }.first
        v['amount_receipt'] ||= 0
        v['amount_payment'] ||= 0

        # after_summeries に同カテゴリのアイテムがなければ即 INSERT し、あれば額のみ足し込み
        if summery.blank?
          after_summeries << v
        else
          idx = after_summeries.find_index(summery)
          v['amount_receipt'] ||= 0
          summery['amount_receipt'] ||= 0
          summery['amount_payment'] ||= 0
          after_summeries[idx] = {
            at_transaction_category_id: v['at_transaction_category_id'],
            category_name1: v['category_name1'],
            category_name2: v['category_name2'],
            amount_receipt: v['amount_receipt'] + summery['amount_receipt'],
            amount_payment: v['amount_payment'] + summery['amount_payment']
          }.stringify_keys
        end
      end
    end
    after_summeries.compact! unless after_summeries.blank?

    after_summeries
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
    pl_category_summery(share, from, to).each { |item|
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
