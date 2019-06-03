class Entities::Goal < ApplicationRecord
  belongs_to :group, optional: true
  belongs_to :user
  has_many :goal_settings
  has_many :goal_logs
end
