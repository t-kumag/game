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

  def get_goal_one(id)
    goal = Entities::Goal.find_by(id: id, group_id: @user.group_id)
    return {} if goal.blank?

    users = {}

    users[:owner] = @user
    users[:partner] = @user.partner_user

    owner_current_amount = get_user_current_amount(users[:owner], goal.id)
    partner_current_amount = get_user_current_amount(users[:partner], goal.id)

    {
        goal_id: goal.id,
        goal_type_id: goal.goal_type_id,
        name: goal.name,
        img_url: goal.img_url,
        goal_amount: goal.goal_amount,
        current_amount: goal.current_amount,
        start_date: goal.start_date,
        end_date: goal.end_date,
        owner_current_amount: owner_current_amount,
        partner_current_amount: partner_current_amount,
        goal_settings: goal.goal_settings
    }
  end

  def self.get_update_goal_data(goal, goal_setting)
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

  def first_amount(goal, goal_setting, add_amount)
    begin
      ActiveRecord::Base.transaction do
        Services::GoalLogService.add_first_amount_insert(goal, goal_setting)
        goal.current_amount += add_amount
        goal.save!
      end
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      raise exception
    end
  end

  def add_money(goal, goal_setting, add_amount)
    begin
      ActiveRecord::Base.transaction do
        Services::GoalLogService.add_amount_insert(goal, goal_setting, add_amount)
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

  def get_user_current_amount(user, goal_id)
    goal_logs = Entities::GoalLog.where(user_id: user.id, goal_id: goal_id)
    monthly_amount = get_monthly_amount_sum(goal_logs)
    first_amount = get_first_amount_sum(goal_logs)
    add_amount = get_add_amount_sum(goal_logs)

    {
        monthly_amount: monthly_amount,
        first_amount: first_amount,
        current_amount: monthly_amount + first_amount + add_amount,  #月々の積立金(monthly_amount) + 初回入金(first_amount) + 追加入金(add_amount)
        add_amount: add_amount
    }
  end

  private

  def get_monthly_amount_sum(goal_logs)
    goal_logs.sum{|i| i.monthly_amount }
  end

  def get_first_amount_sum(goal_logs)
    goal_logs.sum{|i| i.first_amount }
  end

  def get_add_amount_sum(goal_logs)
    goal_logs.sum{|i| i.add_amount }
  end
end