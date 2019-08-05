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
    goal = Entities::Goal.find_by(id: id, group_id: @user.group_id)
    return {} if goal.blank?
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

  def get_update_goal_data(goal, goal_setting)
    {
        id: goal.id,
        goal_type_id: goal.goal_type_id,
        group_id: goal.group_id,
        user_id: goal.user_id,
        name: goal.name,
        img_url: goal.img_url,
        goal_amount: goal.goal_amount,
        current_amount: goal.current_amount + goal_setting.monthly_amount
    }
  end

  def add_money(goal, goal_setting, add_amount)
    begin
      ActiveRecord::Base.transaction do
        Entities::GoalLog.insert(goal, goal_setting, add_amount)
        goal.current_amount += add_amount
        goal.save!
      end
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      raise exception
    end
  end

  def check_bank_balance(add_amount, goal_setting)
    if add_amount.blank? || goal_setting.try(:at_user_bank_account).blank?
      false
    elsif add_amount < goal_setting.try(:at_user_bank_account).try(:balance)
      true
    else
      false
    end
  end

  def self.check_goal_limit_of_free_user(user)
    user.free? && Entities::Goal.where(user_id: user.id).count < Settings.at_user_limit_free_goal
  end

  def get_goal_user_log_data(goal, goal_setting)
    {
        goal_id: goal_setting.goal_id,
        at_user_bank_account_id:  goal_setting.at_user_bank_account_id,
        add_amount: 0,
        monthly_amount: goal_setting.monthly_amount,
        first_amount: goal_setting.first_amount,
        before_current_amount: goal.current_amount,
        after_current_amount: goal.current_amount + goal_setting.monthly_amount,
        add_date: DateTime.now,
        goal_amount: goal.goal_amount
    }
  end
end