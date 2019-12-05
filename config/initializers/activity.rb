
module ACTIVITY_TYPE
  NAME = {
      pairing_created:                   { message: 'ペアリングが完了しました。', url: nil},
      financial_account_faild:           { message: '連携に失敗している金融機関があります', url: 'osidori://financial-accounts'},
      goal_created:                      { message: 'あなたが目標貯金「%s」を作成しました', url: 'osidori://goals/%d'},
      goal_created_partner:              { message: 'パートナーが目標貯金「%s」を作成しました', url: 'osidori://goals/%d'},
      goal_updated:                      { message: '目標貯金「%s」が更新されました', url: 'osidori://goals/%d'},
      goal_monthly_accumulation:         { message: '目標貯金「%s」に月々の積立分が貯金されました', url: 'osidori://goals/%d'},
      goal_loss:                         { message: '目標貯金「%s」への貯金ができませんでした（残高不足）', url: 'osidori://goals/%d'},
      goal_add_money:                    { message: '目標貯金「%s」に追加入金分が貯金されました', url: 'osidori://goals/%d'},
      goal_finished:                     { message: 'おめでとうございます！目標貯金「%s」が目標額を達成しました。', url: 'osidori://goals/%d'},
      person_expense_income:             { message: '個人の取引が%d件ありました', url: 'osidori://transactions'},
      person_tran_to_familly:            { message: 'あなたが取引明細を家族画面に振り分けました', url: 'osidori://transactions/%d?type=%s&account_id=%d'},
      person_tran_to_familly_partner:    { message: 'パートナーが取引明細を家族画面に振り分けました', url: 'osidori://transactions/%d?type=%s&account_id=%d'},
      person_account_to_familly:         { message: 'あなたが金融機関を家族画面に登録しました', url: 'osidori://financial-accounts'},
      person_account_to_familly_partner: { message: 'パートナーが金融機関を家族画面に登録しました', url: 'osidori://financial-accounts'},
      familly_expense_income:            { message: '家族の取引が%d件ありました', url: 'osidori://transactions'},
      individual_manual_outcome:         { message: 'あなたが取引明細を手動で作成しました', url: 'osidori://transactions/%d?type=%s'},
      individual_manual_outcome_fam:     { message: 'パートナーが家族の取引明細を手動で作成しました。', url: 'osidori://transactions/%d?type=%s'}
  }.freeze
end
