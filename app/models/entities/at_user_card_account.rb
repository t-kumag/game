class Entities::AtUserCardAccount < ApplicationRecord
  RELATION_KEY = 'at_user_card_id'.freeze

  acts_as_paranoid # 論理削除
  belongs_to :at_user
  has_many :at_user_card_transactions
  has_many :at_scraping_logs
  has_many :at_sync_transaction_logs

  # TODO ReportServiceと合わせて実装する
  def ids
    [1]
  end

  # 今月の引落し額
  def current_month_payment_amount
    current_month = Time.now.strftime("%Y-%m").to_s
    # clm_ym（決済月）が当日の同月の明細、且つ 確定（confirm_typeがC）された明細の支払い金額（payment_amount）の合算
    self.at_user_card_transactions.where(clm_ym: current_month, confirm_type: 'C').sum{|i| i.payment_amount}
    # a = Entities::UserDistributedTransaction.where(at_user_card_transaction_id: at_user_card_transaction_ids).sum{|i| i.amount}
  end

  # 今月の利用額
  def current_month_used_amount
    from = Time.zone.today.beginning_of_month.beginning_of_day
    to = Time.zone.today.end_of_month.end_of_day
    # used_date（利用日付）が当日と同月
    at_user_card_transaction_ids = self.at_user_card_transactions.where(used_date: from..to).pluck(:id)
    # 確定、未確定関係なくのuser_distributed_transactionsのamountの合算
    Entities::UserDistributedTransaction.where(at_user_card_transaction_id: at_user_card_transaction_ids).sum{|i| i.amount}
  end
  
end
