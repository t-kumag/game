class Entities::AtUserBankAccount < ApplicationRecord
  belongs_to :at_user
  belongs_to :at_bank
  has_many :at_user_bank_transactions
end
