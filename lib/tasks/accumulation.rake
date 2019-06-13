namespace :accumulation do

  desc "目標金額に応じて自動積立する"
  task move_money: :environment do
    Entities::User.find_each do |user|
      goal = Entities::Goal.find_by(user_id: user.id)
      if goal.present? && check_move_money(goal)
        p goal.goal_amount
        p goal.current_amount
      end
    end

  end

  private
  def check_move_money(goal)
    if goal.goal_amount >= goal.current_amount
      return true
    end
  end

end
