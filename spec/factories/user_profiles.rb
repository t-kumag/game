FactoryBot.define do
  factory :user_profile, :class => Entities::UserProfile do
    user_id   { 0 }
    birthday  { "2019-01-01" }
    gender    { 0 }
    has_child { 0 }
    push      { true }
  end
end
