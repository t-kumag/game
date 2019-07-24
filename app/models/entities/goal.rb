class Entities::Goal < ApplicationRecord
  acts_as_paranoid

  belongs_to :group, optional: true
  belongs_to :user
  has_many :goal_settings
  has_many :goal_logs
end
