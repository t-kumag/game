class Entities::AtUserCardAccount < ApplicationRecord
  belongs_to :at_user
  belongs_to :at_card

  def amount
    return 0
  end

end

