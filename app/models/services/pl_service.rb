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
        udt.share = #{share}
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
        udt.share = #{share}
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
        udt.share = #{share}
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
    pl_category_summeries = []
    pl_bank = bank_category_summary(share, from, to)
    pl_category_summery = merge_category_summery(pl_bank, pl_category_summeries)
  #   pl_card = Services::PlService.new(@user.id).card_category_summary(share, from, to)
  #   pl_category_summery = merge_summery(pl_card, pl_category_summery)
  #   pl_emoney = Services::PlService.new(@user.id).emoney_category_summary(share, from, to)
  #   merge_summery(pl_emoney, pl_category_summery)
  end

  def pl_summery(share, from=Time.zone.today.beginning_of_month, to=Time.zone.today.end_of_month)

  end

  # TODO 集計が複雑になったのでもう少しSQLでがんばったほうがいいかも
  def merge_category_summery(pl_categories, pl_category_summeries)
    i = 0
    unless pl_categories.blank?
      pl_categories.each do |pl_category|
        pl_category_summeries.each do |key, pl_category_summery|
          if pl_category_summery[:at_transaction_category_id].has_key? && pl_category[:at_transaction_category_id] == pl_category_summery[:at_transaction_category_id]
            pl_category_summeries[key][:amount_receipt] += pl_category[:amount_receipt]
          else
            pl_category_summeries[i][:amount_receipt] = pl_category[:amount_receipt]
          end
          i += 1
        end
      end
      pl_category_summeries
    end
  end
end
