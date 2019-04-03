class Entities::Goal < ApplicationRecord
  belongs_to :group
  belongs_to :user
  has_many :goal_settings
end
