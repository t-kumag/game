class Entities::AtUserCardAccount < ApplicationRecord
  belongs_to :at_user
  belongs_to :at_card
  has_many :at_user_card_transactions

  def current_month_payment
    current_month = Time.now.strftime("%Y%m").to_s
    self.at_user_card_transactions.where(confirm_type: 'C', clm_ym: current_month ).sum{|i| i.amount}
  end

end
