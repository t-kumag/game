FactoryBot.define do
  factory :user_manually_created_transaction, :class => Entities::UserManuallyCreatedTransaction do
    user_id                    { nil }
    at_transaction_category_id { 1 }
    payment_method_id          { nil }
    used_date                  { "2019/12/31" }
    title                      { nil }
    amount                     { 10000 }
    used_location              { "test" }

    trait :with_user_distributed_transaction do
      after(:create) do |user_manually_created_transaction|
        user_manually_created_transaction.user_distributed_transaction = create(:user_distributed_transaction, user_id: user_manually_created_transaction.user_id)
      end
    end
    
  end
end
