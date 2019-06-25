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

  def update_current_amount(goal, goal_setting)
    create_goal_user_log(goal, goal_setting)
    goal.current_amount = goal.current_amount + goal_setting.monthly_amount
    goal.save!
  end

  def add_money(goal, goal_setting, add_amount)
    res = {}
    begin
        at_user_bank_account = @user.at_user.at_user_bank_accounts.find(goal_setting.at_user_bank_account_id)
        return res["json"] = {}, res["status"] = 400 unless at_user_bank_account.present?

        if add_amount < at_user_bank_account.balance
          ActiveRecord::Base.transaction do
            before_current_amount = goal.current_amount
            after_current_amount = goal.current_amount + add_amount
            goal.current_amount += add_amount
            goal.save!
            
            goal.goal_logs.create!(
              goal_id: goal.id,
              at_user_bank_account_id:  goal_setting.at_user_bank_account_id,
              add_amount: add_amount,
              before_current_amount: before_current_amount,
              after_current_amount: after_current_amount
            )
          end
          res["json"] = {}, res["status"] = 200
        else
          res["json"] = {errors: [{code:"", message:"minus balance"}]}, res["status"] = 422
        end
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
      p "exception===================="
      p exception
    end

    return res
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