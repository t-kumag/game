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

  def get_goal_user(group_id)
    Entities::Goal.find_by(user_id: @user.id, group_id: group_id)
  end

  def get_goal_one(id)
    goal = Entities::Goal.find_by(id)
    {
        goal_id: goal.id,
        goal_type_id: goal.goal_type_id,
        name: goal.name,
        img_url: goal.img_url,
        goal_amount: goal.goal_amount,
        current_amount: goal.current_amount,
        goal_difference_amount: goal.goal_amount - goal.current_amount,
        start_date: goal.start_date,
        end_date: goal.end_date,
        goal_settings: goal.goal_settings
    }
  end

  def update_current_amount(goal, goal_setting)
    create_goal_user_log(goal, goal_setting)
    goal.current_amount = goal.current_amount + goal_setting.monthly_amount
    goal.save!
  end

  private

  def create_goal_user_log(goal, goal_setting)
    goal.goal_logs.create!(
        goal_id: goal_setting.goal_id,
        at_user_bank_account_id:  goal_setting.at_user_bank_account_id,
        add_amount: 0,
        monthly_amount: goal_setting.monthly_amount,
        first_amount: goal_setting.first_amount,
        before_current_amount: goal.current_amount,
        after_current_amount: goal.current_amount + goal_setting.monthly_amount,
        add_date: DateTime.now,
        goal_amount: goal.goal_amount
        )
  end


end