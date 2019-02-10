class Entities::AtUserBankTransaction < ApplicationRecord
  belongs_to :at_bank_account

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
