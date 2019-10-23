FactoryBot.define do
  factory :goal_type, :class => Entities::GoalType do
    img_url { 'test.png' }
    name    { '住宅購入/頭金' }

    trait :all_goal_type do
      after(:create) do |goal_type|
        create(:goal_type, name: '子供教育資金')
        create(:goal_type, name: '結婚/旅行')
        create(:goal_type, name: 'とりあえず貯金')
        create(:goal_type, name: '老後資金')
        create(:goal_type, name: '繰り上げ返済')
        create(:goal_type, name: '車/バイク')
        create(:goal_type, name: 'その他')
      end
    end
  end
end