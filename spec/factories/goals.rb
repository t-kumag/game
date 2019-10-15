FactoryBot.define do
  factory :goal, :class => Entities::Goal do
    group_id       { nil }
    user_id        { nil }
    goal_type_id   { 1 }
    name           { nil }
    img_url        { 'test.png' }
    start_date     { '2019/01/01' }
    end_date       { '2019/12/31' }
    goal_amount    { 1000000 }
    current_amount { 0 }
    deleted_at     { nil }

    trait :with_goal_settings do
      after(:create) do |goal|
        user = Entities::User.find(goal.user_id)
        goal.goal_settings = []
        goal.goal_settings << create(:goal_setting, 
          goal_id: goal.id, 
          at_user_bank_account_id: user.at_user.at_user_bank_accounts.first.id,
          monthly_amount: 100000,
          first_amount: 0,
          user_id: user.id
        )
        goal.goal_settings << create(:goal_setting,
          goal_id: goal.id, 
          at_user_bank_account_id: nil,
          monthly_amount: 100000,
          first_amount: 0,
          user_id: user.partner_user.id
        )
      end
    end
  end
end