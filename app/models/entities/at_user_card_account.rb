# == Schema Information
#
# Table name: at_user_card_accounts
#
#  id            :bigint(8)        not null, primary key
#  at_user_id    :bigint(8)
#  at_card_id    :bigint(8)
#  share         :boolean
#  fnc_id        :string(255)      not null
#  fnc_cd        :string(255)      not null
#  fnc_nm        :string(255)      not null
#  corp_yn       :string(255)      not null
#  brn_cd        :string(255)
#  brn_nm        :string(255)
#  acct_no       :string(255)
#  memo          :string(255)
#  use_yn        :string(255)      not null
#  cert_type     :string(255)      not null
#  scrap_dtm     :datetime         not null
#  last_rslt_cd  :string(255)
#  last_rslt_msg :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Entities::AtUserCardAccount < ApplicationRecord
  acts_as_paranoid # 論理削除
  belongs_to :at_user
  belongs_to :at_card
  has_many :at_user_card_transactions
  has_many :at_scraping_logs
  has_many :at_sync_transaction_logs

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
