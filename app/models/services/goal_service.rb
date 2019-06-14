class Services::GoalService
  def initialize(user)
    @user = user
  end

  def goal_amount(account_ids)
    amount = 0
    Entities::GoalLog.where(at_user_bank_account_id: account_ids).each do |gl|
      amount += gl.add_amount + gl.monthly_amount + gl.first_amount
    end
    amount
  end

  def get_goal_user
    return Entities::Goal.find_by(user_id: @user.id)
  end

  def update_current_amount(goal, goal_setting)
    goal =  Entities::Goal.find_by(user_id: user.id)
    goal.current_amount = goal.current_amount + goal_setting.monthly_amount
    create_goal_user_log(goal, goal_setting)
    goal.save!
  end

  private

  def create_goal_user_log(goal, goal_setting)
    goal.goal_logs.create!(
        goal_id: goal_setting.goal_id,
        at_user_bank_account_id:  goal_setting.at_user_bank_account_id,
        add_amount: goal_setting.monthly_amount,
        monthly_amount: goal_setting.monthly_amount,
        first_amount: goal_setting.first_amount,
        before_current_amount: goal.current_amount,
        after_current_amount: goal.current_amount + goal_setting.monthly_amount,
        before_goal_amount: goal.goal_amount,
        after_goal_amount: goal.goal_amount,
        )
  end


end