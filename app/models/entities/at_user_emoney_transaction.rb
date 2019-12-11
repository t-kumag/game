# == Schema Information
#
# Table name: at_user_emoney_transactions
#
#  id                                :bigint(8)        not null, primary key
#  at_user_emoney_service_account_id :bigint(8)
#  used_date                         :date             not null
#  used_time                         :string(255)
#  description                       :string(255)
#  amount_receipt                    :decimal(16, 2)   not null
#  amount_payment                    :decimal(16, 2)   not null
#  balance                           :decimal(18, 2)
#  seq                               :integer          not null
#  at_transaction_category_id        :bigint(8)        not null
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  confirm_type                      :string(255)
#

class Entities::AtUserEmoneyTransaction < ApplicationRecord
  RELATION_KEY = :at_user_emoney_transaction_id.freeze
  DATE_COLUMN = :used_date.freeze
  belongs_to :at_user_emoney_service_account
  has_one :user_distributed_transaction

  validates :at_transaction_category_id, presence: true

  def amount
    if self.amount_receipt != 0
      return self.amount_receipt
    elsif self.amount_payment != 0 
      return self.amount_payment * -1
    else
      return 0
    end
  end
  
  def date
    self.used_date
  end
end
