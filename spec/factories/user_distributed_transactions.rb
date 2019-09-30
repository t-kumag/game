FactoryBot.define do
  factory :user_distributed_transaction, :class => Entities::UserDistributedTransaction do
    user_id                              { nil }
    group_id                             { nil }
    share                                { 0 }
    used_date                            { "2019/12/31" }
    at_user_bank_transaction_id          { nil }
    at_user_card_transaction_id          { nil }
    at_user_emoney_transaction_id        { nil }
    user_manually_created_transaction_id { nil }
    used_location                        { "test" }
    amount                               { 10000 }
    at_transaction_category_id           { 1 }
 
  end
end
