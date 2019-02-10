class Entities::AtUserCardTransaction < ApplicationRecord
  belongs_to :at_card_account

  def date
    self.used_date
  end

  def description
    self.branch_desc
  end
end

