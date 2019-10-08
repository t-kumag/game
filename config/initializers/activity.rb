
module ACTIVITY_TYPE
  NAME = {
      pairing_created:               { message: 'ペアリングが完了しました。', url: nil},
      financial_account_faild:       { message: '連携に失敗している金融機関があります', url: 'osidori://financial-accounts'},
      goal_created:                  { message: 'あなたが目標貯金「%s」を作成しました', url: 'osidori://'},
      goal_created_partner:          { message: 'パートナーが目標貯金「%s」を作成しました', url: 'osidori://'},
      goal_updated:                  { message: '目標貯金「%s」が更新されました', url: 'osidori://'},
      goal_monthly_accumulation:     { message: '目標貯金「%s」に月々の積立分が貯金されました', url: 'osidori://'},
      goal_loss:                     { message: '目標貯金「%s」への貯金ができませんでした（残高不足）', url: 'osidori://'},
      goal_add_money:                { message: '目標貯金「%s」に追加入金分が貯金されました', url: 'osidori://'},
      goal_finished:                 { message: 'おめでとうございます！目標貯金「%s」が目標額を達成しました。', url: 'osidori://'},
      person_expend_rev:             { message: '個人の取引が%d件ありました', url: 'osidori://transactions'},
      person_expend_to_fam:          { message: 'あなたが取引を家族ホームに振り分けました', url: 'osidori://transactions/%d'},
      person_expend_to_fam_partner:  { message: 'パートナーが取引を家族ホームに振り分けました', url: 'osidori://transactions/%d'},
      person_account_to_fam:         { message: 'あなたの口座を家族ホームに移行しました', url: 'osidori://financial-accounts'},
      person_account_to_fam_partner: { message: 'パートナーの口座が家族ホームに移行しました。', url: 'osidori://financial-accounts'},
      individual_manual_outcome:     { message: 'あなたが取引明細を手動で作成しました', url: 'osidori://transactions/%d'},
      fam_expend_rev:                { message: '家族の取引が%d件ありました', url: 'osidori://transactions'},
      individual_manual_outcome_fam: { message: '夫婦の明細が手動で作成されました。', url: 'osidori://transactions/%d'}
  }.freeze
end