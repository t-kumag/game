FactoryBot.define do
  factory :at_user_bank_transaction, :class => Entities::AtUserBankTransaction do
    at_user_bank_account_id    { nil }
    trade_date                 { "2019/01/01" }
    description1               { "ミロク商店 支払" }
    description2               { nil }
    description3               { nil }
    description4               { nil }
    description5               { nil }
    amount_receipt             { 0 }
    amount_payment             { 0 }
    balance                    { 0 }
    currency                   { "JPY" }
    seq                        { 1 }
    at_transaction_category_id { 1 }
    confirm_type               { nil }

    trait :with_at_user_bank_transactions do
      after(:create) do |at_user_bank_transaction|
        at_user_bank_transaction.user_distributed_transaction = 
          create(
            :user_distributed_transaction, 
            at_user_bank_transaction_id: at_user_bank_transaction.id
          )
      end
    end
  end
end
