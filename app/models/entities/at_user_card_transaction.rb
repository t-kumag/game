# == Schema Information
#
# Table name: at_user_card_transactions
#
#  id                         :bigint(8)        not null, primary key
#  at_user_card_account_id    :bigint(8)
#  used_date                  :date             not null
#  branch_desc                :string(255)      not null
#  amount                     :decimal(16, 2)   not null
#  payment_amount             :decimal(16, 2)   not null
#  trade_gubun                :string(255)      not null
#  etc_desc                   :string(255)
#  clm_ym                     :string(255)      not null
#  crdt_setl_dt               :string(255)
#  seq                        :integer          not null
#  card_no                    :string(255)
#  at_transaction_category_id :bigint(8)        not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  confirm_type               :string(255)
#

class Entities::AtUserCardTransaction < ApplicationRecord
  belongs_to :at_card_account
  has_one :user_distributed_transaction

  def date
    self.used_date
  end

  def description
    self.branch_desc
  end
end

