
module ACTIVITY_TYPE
  NAME = {
      pairing_created:                   { message: 'ペアリングが完了しました。', url: nil},
      financial_account_faild:           { message: '連携に失敗している金融機関があります', url: 'osidori://financial-accounts'},
      goal_created:                      { message: 'あなたが目標貯金「%s」を作成しました', url: 'osidori://'},
      goal_created_partner:              { message: 'パートナーが目標貯金「%s」を作成しました', url: 'osidori://'},
      goal_updated:                      { message: '目標貯金「%s」が更新されました', url: 'osidori://'},
      goal_monthly_accumulation:         { message: '目標貯金「%s」に月々の積立分が貯金されました', url: 'osidori://'},
      goal_fail_no_account:              { message: '目標貯金「%s」への貯金ができませんでした。目標貯金に口座が設定されていません。', url: 'osidori://'},
      goal_fail_short_of_money:          { message: '目標貯金「%s」への貯金ができませんでした。設定された口座が残高不足です。', url: 'osidori://'},
      goal_add_money:                    { message: '目標貯金「%s」に追加入金分が貯金されました', url: 'osidori://'},
      goal_finished:                     { message: 'おめでとうございます！目標貯金「%s」が目標額を達成しました。', url: 'osidori://'},
      person_expense_income:             { message: '個人の取引が%d件ありました', url: 'osidori://transactions'},
      person_tran_to_familly:            { message: 'あなたが取引明細を家族画面に振り分けました', url: 'osidori://transactions/%d'},
      person_tran_to_familly_partner:    { message: 'パートナーが取引明細を家族画面に振り分けました', url: 'osidori://transactions/%d'},
      person_account_to_familly:         { message: 'あなたが登録金融機関を家族画面に移動しました', url: 'osidori://financial-accounts'},
      person_account_to_familly_partner: { message: 'パートナーが登録金融機関を家族画面に移動しました', url: 'osidori://financial-accounts'},
      familly_expense_income:            { message: '家族の取引が%d件ありました', url: 'osidori://transactions'},
      individual_manual_outcome:         { message: 'あなたが取引明細を手動で作成しました', url: 'osidori://transactions/%d'},
      individual_manual_outcome_fam:     { message: 'パートナーが家族の取引明細を手動で作成しました。', url: 'osidori://transactions/%d'}
  }.freeze
end