class Entities::AtUserEmoneyServiceAccount < ApplicationRecord
  belongs_to :at_user
  belongs_to :at_emoney_service
  has_many :at_user_emoney_transactions

end
