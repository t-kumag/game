class Entities::Activity < ApplicationRecord

  validates :user_id, presence: true
end
