class Entities::AtUserCardAccount < ApplicationRecord
  belongs_to :at_user
  belongs_to :at_card_id
end
