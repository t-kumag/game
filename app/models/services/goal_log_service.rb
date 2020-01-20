class Services::GoalLogService

  def self.add_amount_insert(goal, goal_setting, add_amount=0)
    params = {
        goal_id: goal.id,
        at_user_bank_account_id: goal_setting.at_user_bank_account_id,
        monthly_amount: 0,
        first_amount: 0,
        add_amount: add_amount,
        before_current_amount: goal.current_amount,
        after_current_amount: goal.current_amount + add_amount,
        goal_amount: goal.goal_amount,
        user_id: goal_setting.user_id,
        add_date: DateTime.now
    }
    Entities::GoalLog.create!(params)
  end

  def self.add_first_amount_insert(goal, goal_setting)
    params = {
        goal_id: goal.id,
        at_user_bank_account_id: goal_setting.at_user_bank_account_id,
        wallet_id: goal_setting.wallet_id,
        monthly_amount: 0,
        first_amount: goal_setting.first_amount,
        add_amount: 0,
        before_current_amount: goal.current_amount,
        after_current_amount: goal.current_amount + goal_setting.first_amount,
        goal_amount: goal.goal_amount,
        user_id: goal_setting.user_id,
        add_date: DateTime.now
    }
    Entities::GoalLog.create!(params)
  end

  def self.add_monthly_amount_insert(goal, goal_setting)
    params = {
        goal_id: goal.id,
        at_user_bank_account_id: goal_setting.at_user_bank_account_id,
        monthly_amount: goal_setting.monthly_amount,
        first_amount: 0,
        add_amount: 0,
        before_current_amount: goal.current_amount,
        after_current_amount: goal.current_amount + goal_setting.monthly_amount,
        goal_amount: goal.goal_amount,
        user_id: goal_setting.user_id,
        add_date: DateTime.now
    }
    Entities::GoalLog.create!(params)
  end

  def self.get_goal_log(goal, goal_setting)
    {
        goal_id: goal_setting.goal_id,
        at_user_bank_account_id:  goal_setting.at_user_bank_account_id,
        add_amount: 0,
        monthly_amount: goal_setting.monthly_amount,
        before_current_amount: goal.current_amount,
        after_current_amount: goal.current_amount + goal_setting.monthly_amount,
        user_id: goal_setting.user_id,
        add_date: DateTime.now,
        goal_amount: goal.goal_amount
    }
  end

  def self.update_goal_log(goal, goal_setting, old_goal_log)
    {
        goal_id: goal_setting[:goal_id],
        at_user_bank_account_id:  goal_setting.at_user_bank_account_id,
        add_amount: 0,
        monthly_amount: goal_setting.monthly_amount,
        before_current_amount: old_goal_log[:after_current_amount],
        after_current_amount: old_goal_log[:after_current_amount] + goal_setting.monthly_amount,
        user_id: goal_setting.user_id,
        add_date: DateTime.now,
        goal_amount: goal[:goal_amount]
    }
  end

  def self.alreday_exist_first_amount(goal_id, user_id)
    Entities::GoalLog.where(goal_id: goal_id, user_id: user_id).where("first_amount > 0").present?
  end
end