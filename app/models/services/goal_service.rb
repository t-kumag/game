class Services::GoalService
  def initialize(user)
    @user = user
  end

  def goal_amount
    Entities::Goal.where(group_id: @user.group_id).sum{|i| i.goal_amount}
  end

  def self.sum_goal_settings_goal_amount(goal_settings)
    goal_settings.map { |g| g.goal.goal_amount }.sum
  end
end