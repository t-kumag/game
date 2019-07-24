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
#

# FactoryBot.define do
#   factory :at_user_token do
#     at_user nil
#     token "MyString"
#     expires_at "2018-09-04 06:49:35"
#   end
# end
