class Entities::GoalLog < ApplicationRecord
  belongs_to :goal
  belongs_to :at_user_bank_account, optional: true

  # Entities::GoalLog.insert(goal, goal_setting)
  def self.insert(goal, goal_setting, add_amount=0)
    params = {
      goal_id: goal.id,
      at_user_bank_account_id: goal_setting.at_user_bank_account_id,
      monthly_amount: goal_setting.at_user_bank_account_id,
      first_amount: goal_setting.at_user_bank_account_id,
      add_amount: add_amount,
      before_current_amount: goal.current_amount,
      after_current_amount: goal.current_amount + add_amount
    }
    self.create!(params)

  end

end
