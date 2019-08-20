# == Schema Information
#
# Table name: users
#
#  id                  :bigint(8)        not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  email               :string(255)
#  token               :string(255)
#  password_digest     :string(255)
#  email_authenticated :boolean          default(FALSE)
#  token_expires_at    :datetime
#

FactoryBot.define do
  factory :user, :class => Entities::User do
    email { "test@test.com" }
    # ベアラートークン
    token { "test" }
    password_digest { "test" }
    # メール認証
    email_authenticated { 1 }
    token_expires_at { "2020/01/01 00:00:00" }
    # 有料会員
    rank { 0 }
    deleted_at { nil }
  end
end
