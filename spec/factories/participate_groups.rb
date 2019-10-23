FactoryBot.define do
  factory :participate_group, :class => Entities::ParticipateGroup do
    group_id   { nil }
    user_id    { nil }
    deleted_at { nil }
  end
end