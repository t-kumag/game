FactoryBot.define do
  factory :at_user_bank_account, :class => Entities::AtUserBankAccount do
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
    scrap_dtm	    { "2019/08/22 00:00:00" }
    last_rslt_cd  { 0 }
    last_rslt_msg	{ "正常" }
    deleted_at    { nil }
    group_id      { nil }
    error_date    { nil }
    error_count   { 0 }

    trait :with_at_user_bank_transactions do
      after(:create) do |at_user_bank_account|
        at_user_bank_account.at_user_bank_transactions = []
        at_user_bank_account.at_user_bank_transactions << 
        create(
          :at_user_bank_transaction, 
          :with_at_user_bank_transactions, 
          at_user_bank_account_id: at_user_bank_account.id
        )
      end
    end
  end
end
