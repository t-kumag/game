FactoryBot.define do
  factory :goal_setting, :class => Entities::GoalSetting do
    goal_id                 { nil }
    at_user_bank_account_id { nil }
    monthly_amount          { 0 }
    first_amount            { 0 }
    user_id                 { nil }
  end
end