class Entities::AtUserEmoneyTransaction < ApplicationRecord
  belongs_to :at_emoney_service_account


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
