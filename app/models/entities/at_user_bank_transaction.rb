class Entities::AtUserBankTransaction < ApplicationRecord
  belongs_to :at_bank_account

  def amount
    if self.amount_receipt != nil 
      return self.amount_receipt
    elsif self.amount_payment != nil 
      return self.amount_payment
    else
      return 0
    end
  end

end
