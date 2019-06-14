class Services::GoalLogService

  def create_log(goal,goal_setting)
    goal_log = Entities::GoalLog.new
    goal_log.goal_id = goal_setting.goal_id
    goal_log.at_user_bank_account_id = goal_setting.at_user_bank_account_id
    goal_log.add_amount = goal_setting.monthly_amount
    goal_log.monthly_amount = goal_setting.monthly_amount
    goal_log.first_amount = goal_setting.first_amount
    goal_log.before_current_amount = goal.current_amount
    goal_log.after_current_amount = goal.current_amount + goal_setting.monthly_amount
    goal_log.before_goal_amount = goal.goal_amount
    goal_log.after_goal_amount = goal.goal_amount
    goal_log.save!
  end


end