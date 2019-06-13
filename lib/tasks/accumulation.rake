namespace :accumulation do
  desc "目標金額に応じて自動積立する"
  task move_money: :environment do
    Entities::User.find_each do |user|
    end
  end
end
