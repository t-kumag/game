class Entities::AtUserBankAccount < ApplicationRecord
  belongs_to :at_user
  belongs_to :at_bank

end
