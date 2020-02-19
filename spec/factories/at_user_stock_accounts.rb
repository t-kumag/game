FactoryBot.define do
  factory :at_user_stock_account, :class => Entities::AtUserStockAccount do
    at_user_id    { 0 }
    balance       { 10000000 }
    share         { 0 }
    fnc_id        { "test" }
    fnc_cd        { "99999999" }
    fnc_nm        { "ミロク情報銀行" }
    corp_yn       { "N" }
    brn_cd        { "test" }
    brn_nm        { "test" }
    acct_no       { "test" }
    acct_kind     { "test" }
    memo          { "test" }
    use_yn        { "Y" }
    cert_type	    { "1" }
    sv_type       { "1"}
    scrap_dtm	    { "2019/08/22 00:00:00" }
    last_rslt_cd  { 0 }
    last_rslt_msg	{ "正常" }
    deleted_at    { nil }
    group_id      { nil }
    error_date    { nil }
    error_count   { 0 }

    trait :with_at_user_asset_products do
      after(:create) do |at_user_stock_account|
        at_user_stock_account.at_user_asset_products = []
        at_user_stock_account.at_user_asset_products <<
            create(
                :at_user_asset_product,
                at_user_stock_account_id: at_user_stock_account.id
            )
      end
    end
  end
end
