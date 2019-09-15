FactoryBot.define do
  factory :at_user_card_account, :class => Entities::AtUserCardAccount do
    at_user_id    { 0 }
    at_card_id    { 0 }
    share         { 0 }
    fnc_id        { "test" }
    fnc_cd        { "39999999" }
    fnc_nm        { "ミロク情報カード" }
    corp_yn       { "N" }
    brn_cd        { "test" }
    brn_nm        { "test" }
    acct_no       { "test" }
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

    at_card
  end
end