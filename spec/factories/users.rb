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
    sequence(:email)    { |n| "test#{n}@example.com"}
    token               { "test" } # ベアラートークン
    password_digest     { "testtest" }
    email_authenticated { 1 } # メール認証
    token_expires_at    { "2020/01/01 00:00:00" }
    rank                { 0 } # 有料会員
    deleted_at          { nil }

    trait :with_at_user do
      after(:create) do |user|
        user.at_user = create(:at_user, user_id: user.id)
      end
    end

    trait :with_at_user_at_user_bank_accounts do
      after(:create) do |user|
        user.at_user = create(:at_user, user_id: user.id)
        user.at_user.at_user_bank_accounts = []
        user.at_user.at_user_bank_accounts << create(:at_user_bank_account, at_user_id: user.at_user.id)
      end
    end
    
  end
end
