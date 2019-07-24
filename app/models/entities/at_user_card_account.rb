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

  def current_month_payment(account_ids=nil)
    current_month = Time.now.strftime("%Y-%m").to_s
    if account_ids.present?
      self.at_user_card_transactions.where(confirm_type: 'C', clm_ym: current_month, at_user_card_account_id: account_ids).sum{|i| i.amount}
    else
      self.at_user_card_transactions.where(confirm_type: 'C', clm_ym: current_month ).sum{|i| i.amount}
    end
  end

end
