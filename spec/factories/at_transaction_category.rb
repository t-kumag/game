FactoryBot.define do
  factory :at_transaction_category, :class => Entities::AtTransactionCategory do
    at_category_id         { 1 }
    category_name1         { "未分類" }
    category_name2         { "未分類" }
    at_grouped_category_id { 1 }
    
  end
end