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

end