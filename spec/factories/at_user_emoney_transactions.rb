FactoryBot.define do
  factory :at_user_emoney_transaction, :class => Entities::AtUserEmoneyTransaction do
    at_user_emoney_service_account_id { nil }
    used_date                         { "2019/01/01" }
    used_time                         { "00:00:00" }
    description                       { "お支払い ミロクコーヒー" }
    amount_receipt                    { 0 }
    amount_payment                    { 0 }
    balance                           { 0 }
    seq                               { 1 }
    at_transaction_category_id        { 1 }
    confirm_type                      { nil }

    trait :with_at_user_emoney_transactions do
      after(:create) do |at_user_emoney_transaction|
        at_user_emoney_transaction.user_distributed_transaction = 
          create(
            :user_distributed_transaction, 
            at_user_emoney_transaction_id: at_user_emoney_transaction.id
          )
      end
    end
  end
end