FactoryBot.define do
  factory :at_grouped_category, :class => Entities::AtGroupedCategory do
    category_name { "未分類" }
    version {1}
    category_type {"expense"}
    order_key {1}

    trait :with_at_transaction_categories do
      after(:create) do |at_grouped_category|
        at_grouped_category.at_transaction_categories = []
        at_grouped_category.at_transaction_categories << create(:at_transaction_category,
          at_category_id: 1,
          category_name1: "未分類",
          category_name2: "未分類",
          at_grouped_category_id: 1
        )
      end
    end

    trait :v2_at_grouped_category do
      after(:create) do |at_grouped_category|
        v2_at_grouped_category = create(:at_grouped_category, version: 2)
        create(:at_transaction_category,
          at_category_id: 2,
          category_name1: "未分類",
          category_name2: "未分類",
          at_grouped_category_id: v2_at_grouped_category.id,
          before_version_id: 1
        )
      end
    end
  end
end
