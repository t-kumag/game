class Entities::GoalLog < ApplicationRecord
  belongs_to :goal
  belongs_to :at_user_bank_account, optional: true

  validates :goal_id, presence: true, on: :create

end
