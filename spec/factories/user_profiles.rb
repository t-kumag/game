FactoryBot.define do
  factory :user_profile, :class => Entities::UserProfile do
    gender { 0 }
    birthday { "2019-01-01" }
    has_child { 0 }
    push { true }
  end
end
