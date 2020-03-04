FactoryBot.define do
  factory :at_user_emoney_service_account, :class => Entities::AtUserEmoneyServiceAccount do
    at_user_id           { 0 }
    balance              { 0 }
    share                { 0 }
    fnc_id               { "test" }
    fnc_cd               { "G9999999" }
    fnc_nm               { "ミロクスイカ" }
    corp_yn              { "N" }
    acct_no              { "test" }
    memo                 { "test" }
    use_yn               { "Y" }
    cert_type            { "1" }
    scrap_dtm            { "2019/08/22 00:00:00" }
    last_rslt_cd         { 0 }
    last_rslt_msg        { "正常" }
    deleted_at           { nil }
    group_id             { nil }
    error_date           { nil }
    error_count          { 0 }

    trait :with_at_user_emoney_transactions do
      after(:create) do |at_user_emoney_service_account|
        at_user_emoney_service_account.at_user_emoney_transactions = []
        at_user_emoney_service_account.at_user_emoney_transactions << 
        create(
          :at_user_emoney_transaction, 
          :with_at_user_emoney_transactions, 
          at_user_emoney_service_account_id: at_user_emoney_service_account.id
        )
      end
    end
  end
end