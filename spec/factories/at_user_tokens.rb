# == Schema Information
#
# Table name: at_user_tokens
#
#  id         :bigint(8)        not null, primary key
#  at_user_id :bigint(8)
#  token      :string(255)
#  expires_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null

FactoryBot.define do
  factory :at_user_token, :class => Entities::AtUserToken do
    at_user_id { nil } 
    token      { "test" }
    expires_at { nil } 
    deleted_at { nil }
  end
end
