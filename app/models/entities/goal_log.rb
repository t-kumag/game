class Entities::GoalLog < ApplicationRecord
  belongs_to :goal
  belongs_to :at_user_bank_account, optional: true

  # Entities::GoalLog.insert(goal, goal_setting)
  def self.insert(goal, goal_setting)
    params = {
      goal_id: goal.id,
      at_user_bank_account_id: goal_setting.at_user_bank_account_id,
      monthly_amount: goal_setting.at_user_bank_account_id,
      first_amount: goal_setting.at_user_bank_account_id
    }
    self.create!(params)

  end

end
