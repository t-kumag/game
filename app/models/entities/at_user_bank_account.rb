# == Schema Information
#
# Table name: at_user_bank_accounts
#
#  id            :bigint(8)        not null, primary key
#  at_user_id    :bigint(8)
#  at_bank_id    :bigint(8)
#  balance       :decimal(18, 2)
#  share         :boolean
#  fnc_id        :string(255)      not null
#  fnc_cd        :string(255)      not null
#  fnc_nm        :string(255)      not null
#  corp_yn       :string(255)      not null
#  brn_cd        :string(255)
#  brn_nm        :string(255)
#  acct_no       :string(255)
#  acct_kind     :string(255)
#  memo          :string(255)
#  use_yn        :string(255)      not null
#  cert_type     :string(255)      not null
#  scrap_dtm     :datetime         not null
#  last_rslt_cd  :string(255)
#  last_rslt_msg :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Entities::AtUserBankAccount < ApplicationRecord
  belongs_to :at_user
  belongs_to :at_bank
  has_many :at_user_bank_transactions
  has_many :goal_settings
end
