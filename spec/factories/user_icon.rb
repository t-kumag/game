FactoryBot.define do
  factory :user_icon, :class => Entities::UserIcon do
    img_url { "test.jpg" }
  end
end
