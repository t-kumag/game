class Entities::UserPurchase < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true
  has_one :app_store_premium_plan
  has_one :google_play_premium_plan
end
