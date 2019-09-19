# == Schema Information
#
# Table name: at_users
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  at_user_id :string(255)

FactoryBot.define do
  factory :at_user, :class => Entities::AtUser do
    user_id    { 0 }
    at_user_id { "test" }
    deleted_at { nil }

    after(:create) do |at_user|
      at_user.at_user_tokens = []
      at_user.at_user_tokens << create(:at_user_token, at_user_id: at_user.id)
    end

    trait :with_at_user_bank_accounts do
      after(:create) do |at_user|
        at_user.at_user_bank_accounts = []
        at_user.at_user_bank_accounts << create(:at_user_bank_account, at_user_id: at_user.id)
      end
    end

    trait :with_at_user_bank_transactions do
      after(:create) do |at_user|
        at_user.at_user_bank_accounts = []
        at_user.at_user_bank_accounts << 
        create(
          :at_user_bank_account, 
          :with_at_user_bank_transactions, 
          at_user_id: at_user.id
        )
      end
    end

    trait :with_at_user_card_accounts do
      after(:create) do |at_user|
        at_user.at_user_card_accounts = []
        at_user.at_user_card_accounts << create(:at_user_card_account, at_user_id: at_user.id)
      end
    end

    trait :with_at_user_card_transactions do
      after(:create) do |at_user|
        at_user.at_user_card_accounts = []
        at_user.at_user_card_accounts << 
        create(
          :at_user_card_account, 
          :with_at_user_card_transactions, 
          at_user_id: at_user.id
        )
      end
    end

    trait :with_at_user_emoney_accounts do
      after(:create) do |at_user|
        at_user.at_user_emoney_service_accounts = []
        at_user.at_user_emoney_service_accounts << create(:at_user_emoney_service_account, at_user_id: at_user.id)
      end
    end

    trait :with_at_user_emoney_transactions do
      after(:create) do |at_user|
        at_user.at_user_emoney_service_accounts = []
        at_user.at_user_emoney_service_accounts << 
        create(
          :at_user_emoney_service_account, 
          :with_at_user_emoney_transactions, 
          at_user_id: at_user.id
        )
      end
    end

  end
end
