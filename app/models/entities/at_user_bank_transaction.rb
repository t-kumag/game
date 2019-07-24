# == Schema Information
#
# Table name: at_user_bank_transactions
#
#  id                         :bigint(8)        not null, primary key
#  at_user_bank_account_id    :bigint(8)        not null
#  trade_date                 :datetime         not null
#  description1               :string(255)      not null
#  description2               :string(255)
#  description3               :string(255)
#  description4               :string(255)
#  description5               :string(255)
#  amount_receipt             :decimal(16, 2)
#  amount_payment             :decimal(16, 2)
#  balance                    :decimal(16, 2)
#  currency                   :string(255)      not null
#  seq                        :integer          not null
#  at_transaction_category_id :bigint(8)        not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  confirm_type               :string(255)
#

class Entities::AtUserBankTransaction < ApplicationRecord
  belongs_to :at_user_bank_account
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
    self.trade_date
  end

  def description
    self.description1
    # t.string "description2"
    # t.string "description3"
    # t.string "description4"
    # t.string "description5"
  end

end
