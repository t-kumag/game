class Entities::GoalSetting < ApplicationRecord
  belongs_to :goal, :dependent => :destroy
  belongs_to :at_user_bank_account, optional: true
end
