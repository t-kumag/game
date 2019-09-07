FactoryBot.define do
  factory :user_icon, :class => Entities::UserIcon do
    user_id { 0 }
    img_url { "test.jpg" }
  end
end
