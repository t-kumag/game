# TODO 目標単位でも集計できるようにする
class Services::PlService
  def initialize(user, with_group=false)
    @user = user
    @with_group = with_group
  end

  def bank_category_summary(share, from=Time.zone.today.beginning_of_month, to=Time.zone.today.end_of_month)
    sql = <<-EOS
      SELECT
        aubt.at_transaction_category_id,
        sum(aubt.amount_receipt) as amount_receipt,
        sum(aubt.amount_payment) as amount_payment,
        atc.category_name1,
        atc.category_name2
      FROM
        user_distributed_transactions as udt
      LEFT OUTER JOIN 
        at_user_bank_transactions as aubt
      ON
        aubt.id = udt.at_user_bank_transaction_id
      LEFT OUTER JOIN
        at_transaction_categories as atc
      ON
        aubt.at_transaction_category_id = atc.id
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
        aubt.at_transaction_category_id
    EOS

    ActiveRecord::Base.connection.select_all(sql).to_hash
  end

  def card_category_summary(share, from=Time.zone.today.beginning_of_month, to=Time.zone.today.end_of_month)
    sql = <<-EOS
      SELECT
        auct.at_transaction_category_id,
        sum(auct.amount) as amount_payment,
        atc.category_name1,
        atc.category_name2
      FROM
        user_distributed_transactions as udt
      LEFT OUTER JOIN 
        at_user_card_transactions as auct
      ON
        auct.id = udt.at_user_card_transaction_id
      LEFT OUTER JOIN
        at_transaction_categories as atc
      ON
        auct.at_transaction_category_id = atc.id
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
        auct.at_transaction_category_id
    EOS

    ActiveRecord::Base.connection.select_all(sql).to_hash
  end

  def emoney_category_summary(share, from=Time.zone.today.beginning_of_month, to=Time.zone.today.end_of_month)
    sql = <<-EOS
      SELECT
        auet.at_transaction_category_id,
        sum(auet.amount_receipt) as amount_receipt,
        sum(auet.amount_payment) as amount_payment,
        atc.category_name1,
        atc.category_name2
      FROM
        user_distributed_transactions as udt
       LEFT OUTER JOIN 
        at_user_emoney_transactions as auet
      ON
        auet.id = udt.at_user_emoney_transaction_id
      LEFT OUTER JOIN
        at_transaction_categories as atc
      ON
        auet.at_transaction_category_id = atc.id
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
        auet.at_transaction_category_id
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

  def pl_category_summery(share, from=Time.zone.today.beginning_of_month, to=Time.zone.today.end_of_month)
    pl_bank = bank_category_summary(share, from, to)

    puts pl_bank

    pl_card = card_category_summary(share, from, to)

    puts pl_card

    pl_emoney = emoney_category_summary(share, from, to)

    puts pl_emoney

    merge_category_summery(pl_emoney, merge_category_summery(pl_card, pl_bank))
  end

  def pl_summery(share, from=Time.zone.today.beginning_of_month, to=Time.zone.today.end_of_month)
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

  def merge_category_summery(pl, before_summeries)
    after_summeries = before_summeries.dup
    unless pl.blank? && after_summeries.blank?
      pl.each do |v|
        next if v['at_transaction_category_id'].blank?
        summery = after_summeries.select {|category_summery|
          next if category_summery.blank? || category_summery['at_transaction_category_id'].blank?
          category_summery['at_transaction_category_id'] == v['at_transaction_category_id']
        }.first
        v['amount_receipt'] ||= 0
        v['amount_payment'] ||= 0
        if summery.blank?
          after_summeries << v
        else
          summery['amount_receipt'] ||= 0
          summery['amount_payment'] ||= 0
          after_summeries[v['at_transaction_category_id']] = {
            at_transaction_category_id: v['at_transaction_category_id'],
            amount_receipt: v['amount_receipt'] + summery['amount_receipt'],
            amount_payment: v['amount_payment'] + summery['amount_payment']
          }.stringify_keys
        end
      end
    end
    after_summeries.compact! unless after_summeries.blank?
    after_summeries
  end

end
