# == Schema Information
#
# Table name: at_user_emoney_service_accounts
#
#  id                   :bigint(8)        not null, primary key
#  at_user_id           :bigint(8)
#  at_emoney_service_id :bigint(8)
#  balance              :decimal(18, 2)
#  share                :boolean
#  fnc_id               :string(255)      not null
#  fnc_cd               :string(255)      not null
#  fnc_nm               :string(255)      not null
#  corp_yn              :string(255)      not null
#  acct_no              :string(255)
#  memo                 :string(255)
#  use_yn               :string(255)      not null
#  cert_type            :string(255)      not null
#  scrap_dtm            :datetime         not null
#  last_rslt_cd         :string(255)
#  last_rslt_msg        :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Entities::AtUserEmoneyServiceAccount < ApplicationRecord
  acts_as_paranoid # 論理削除
  belongs_to :at_user
  belongs_to :at_emoney_service
  has_many :at_user_emoney_transactions
  has_many :at_scraping_logs
  has_many :at_sync_transaction_logs

  def current_month_payment(account_ids=nil)
    if account_ids.present?
      self.at_user_emoney_transactions.where(used_date: (Time.zone.today.beginning_of_month)..(Time.zone.today.end_of_month), at_user_emoney_service_account_id: account_ids).sum{|i| i.amount_payment}
    else
      self.at_user_emoney_transactions.where(used_date: (Time.zone.today.beginning_of_month)..(Time.zone.today.end_of_month)).sum{|i| i.amount_payment}
    end
  end

end
