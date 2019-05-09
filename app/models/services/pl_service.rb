class Services::PlService
  def initialize(user)
    @user = user
  end

  def bank_category_summary(share, from=Time.zone.today.beginning_of_month, to=Time.zone.today.end_of_month)
    sql = <<-EOS
      SELECT
        aubt.at_transaction_category_id,
        sum(aubt.amount_receipt) as amount_receipt,
        sum(aubt.amount_payment) as amount_payment
      FROM
        user_distributed_transactions as udt
      LEFT OUTER JOIN 
        at_user_bank_transactions as aubt
      ON
        aubt.id = udt.at_user_bank_transaction_id
      WHERE
        udt.user_id = #{@user.id}
      AND 
        udt.share in (#{share.join(',')})
      AND
        udt.used_date >= "#{from}"
      AND
        udt.used_date <= "#{to}"
      GROUP BY 
        aubt.at_transaction_category_id
    EOS

    ActiveRecord::Base.connection.select_all(sql).to_hash
  end

  def card_category_summary(share, from=Time.zone.today.beginning_of_month, to=Time.zone.today.end_of_month)
    sql = <<-EOS
      SELECT
        auct.at_transaction_category_id,
        sum(auct.amount) as amount_payment
      FROM
        user_distributed_transactions as udt
      LEFT OUTER JOIN 
        at_user_card_transactions as auct
      ON
        auct.id = udt.at_user_card_transaction_id
      WHERE
        udt.user_id = #{@user.id}
      AND 
        udt.share in (#{share.join(',')})
      AND
        udt.used_date >= "#{from}"
      AND
        udt.used_date <= "#{to}"
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
        sum(auet.amount_payment) as amount_payment
      FROM
        user_distributed_transactions as udt
       LEFT OUTER JOIN 
        at_user_emoney_transactions as auet
      ON
        auet.id = udt.at_user_emoney_transaction_id
      WHERE
        udt.user_id = #{@user.id}
      AND 
        udt.share in (#{share.join(',')})
      AND
        udt.used_date >= "#{from}"
      AND
        udt.used_date <= "#{to}"
      GROUP BY 
        auet.at_transaction_category_id
    EOS

    ActiveRecord::Base.connection.select_all(sql).to_hash
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
