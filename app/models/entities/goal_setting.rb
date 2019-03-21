class Entities::GoalSetting < ApplicationRecord
  belongs_to :goal
  belongs_to :user
  belongs_to :at_user_bank_account
end
