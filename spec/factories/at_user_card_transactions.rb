FactoryBot.define do
  factory :at_user_card_transaction, :class => Entities::AtUserCardTransaction do
    at_user_card_account_id    { nil }
    used_date                  { "2019/01/01" }
    branch_desc                { "居酒屋　ミロクヤ" }
    amount                     { 0 }
    payment_amount             { 0 }
    trade_gubun                { "" }
    etc_desc                   { nil }
    clm_ym                     { "2019-12" }
    crdt_setl_dt               { nil }
    seq                        { 1 }
    card_no                    { nil }
    at_transaction_category_id { 1 }
    confirm_type               { "C" }

  end
end
