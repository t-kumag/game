SELECT
  u.id AS 'ユーザID'
  , available_pg.group_id AS 'ペアリングID'
  , u.created_at AS 'メール登録完了日時'
  , u.email_authenticated AS 'メアド認証'
  , u.email AS 'メールアドレス'
  , CASE WHEN u.deleted_at IS NULL THEN 0 ELSE 1 END AS '退会の有無'
  , CASE WHEN up.gender = 0 THEN "女" WHEN gender = 1 THEN "男" ELSE 0 END AS '性別'
  , COALESCE(up.birthday, 0) AS '生年月日'
  , CASE WHEN has_child > 0 THEN 1 ELSE 0 END AS '子どもの有無'
  , up.push AS 'push許諾'
  , COALESCE(max_step_teble.budget_question_id, 0) AS '診断タイプ'
  , question.Q1 AS 'Q1'
  , question.Q2 AS 'Q2'
  , max_step_teble.Q3 AS 'Q3'

  , COALESCE(financial.is_connected, 0) AS '金融機関連携の有無'
  , COALESCE(financial.min_created_at, 0) AS '金融機関連携の日時(初回連携分)'
  , COALESCE(financial.bank_count, 0) AS '金融機関連携数_銀行'
  , COALESCE(financial.card_count, 0) AS '金融機関連携数_カード'
  , COALESCE(financial.emoney_count, 0) AS '金融機関連携数_電子マネー'

  , COALESCE(all_financial.is_connected, 0) AS '金融機関連携経験の有無'
  , COALESCE(all_financial.bank_count, 0) AS '金融機関総連携数_銀行'
  , COALESCE(all_financial.card_count, 0) AS '金融機関総連携数_カード'
  , COALESCE(all_financial.emoney_count, 0) AS '金融機関総連携数_電子マネー'

  , numbered_bank.bank1 AS '口座１'
  , numbered_bank.bank2 AS '口座２'
  , numbered_bank.bank3 AS '口座３'
  , numbered_bank.bank4 AS '口座４'
  , numbered_bank.bank5 AS '口座５'
  , numbered_card.card1 AS 'クレカ１'
  , numbered_card.card2 AS 'クレカ２'
  , numbered_card.card3 AS 'クレカ３'
  , numbered_card.card4 AS 'クレカ４'
  , numbered_card.card5 AS 'クレカ５'
  , numbered_emoney.emoney1 AS 'IC１'
  , numbered_emoney.emoney2 AS 'IC２'
  , numbered_emoney.emoney3 AS 'IC３'
  , numbered_emoney.emoney4 AS 'IC４'
  , numbered_emoney.emoney5 AS 'IC５'

  , CASE WHEN available_pg.group_id IS NULL THEN 0 ELSE 1 END 'ペアリング有無'
  , CASE WHEN available_pg.group_id IS NULL THEN 0 ELSE available_pg.created_at END AS 'ペアリング完了日時'
  , CASE WHEN available_pg.from_user_id = u.id THEN 1 ELSE 0 END AS 'ペアリング招待者'
  , CASE WHEN available_pg.to_user_id = u.id THEN 1 ELSE 0 END AS 'ペアリング被招待者'

  , CASE WHEN share_financial_g.group_id IS NULL THEN 0 ELSE 1 END '金融機関の共有の有無（夫婦）'
  , CASE WHEN up.gender = 1 THEN COALESCE(share_financial.m_count, 0) ELSE 0 END '金融機関の共有数＿夫が実施'
  , CASE WHEN up.gender = 0 THEN COALESCE(share_financial.f_count, 0) ELSE 0 END '金融機関の共有数＿妻が実施'
  , CASE WHEN up.gender IS NULL THEN COALESCE(share_financial.n_count, 0) ELSE 0 END '金融機関の共有数＿不明が実施'

  , CASE WHEN share_transactions_g.group_id IS NULL THEN 0 ELSE 1 END AS '明細の共有の有無（夫婦）'
  , CASE WHEN up.gender = 1 THEN COALESCE(share_transactions.m_count, 0) ELSE 0 END AS '明細の共有数＿夫が実施'
  , CASE WHEN up.gender = 0 THEN COALESCE(share_transactions.f_count, 0) ELSE 0 END AS '明細の共有数＿妻が実施'
  , CASE WHEN up.gender IS NULL THEN COALESCE(share_transactions.n_count, 0) ELSE 0 END AS '明細の共有数＿不明が実施'

  , COALESCE(share_transactions.m_created_at, 0) AS '明細の共有日時＿夫が実施（個人→夫婦）（初回実施分）'
  , COALESCE(share_transactions.f_created_at, 0) AS '明細の共有日時＿妻が実施（個人→夫婦）（初回実施分）'
  , COALESCE(share_transactions.n_created_at, 0) AS '明細の共有日時＿不明が実施（個人→夫婦）（初回実施分）'

  , COALESCE(goal.count, 0) AS '目標貯金作成数'
  , CASE WHEN COALESCE(goal_g.count, 0) > 0 THEN 1 ELSE 0 END AS '目標貯金の有無（夫婦）'
  , CASE WHEN COALESCE(goal.house, 0) > 0 THEN 1 ELSE 0 END AS '住宅購入/頭金'
  , CASE WHEN COALESCE(goal.child, 0) > 0 THEN 1 ELSE 0 END AS '子供教育資金'
  , CASE WHEN COALESCE(goal.weding, 0) > 0 THEN 1 ELSE 0 END AS '結婚/旅行'
  , CASE WHEN COALESCE(goal.for_now, 0) > 0 THEN 1 ELSE 0 END AS 'とりあえず貯金'
  , CASE WHEN COALESCE(goal.old_age, 0) > 0 THEN 1 ELSE 0 END AS '老後資金'
  , CASE WHEN COALESCE(goal.re_pay, 0) > 0 THEN 1 ELSE 0 END AS '繰り上げ返済'
  , CASE WHEN COALESCE(goal.car, 0) > 0 THEN 1 ELSE 0 END AS '車/バイク'
  , CASE WHEN COALESCE(goal.other, 0) > 0 THEN 1 ELSE 0 END AS 'その他'

  , CASE WHEN up.gender = 1 THEN COALESCE(numberd_goal.goal_created_at1, 0) ELSE 0 END AS '夫が金融機関を目標貯金に連携した時刻１'
  , CASE WHEN up.gender = 1 THEN COALESCE(numberd_goal.goal_created_at2, 0) ELSE 0 END AS '夫が金融機関を目標貯金に連携した時刻２'
  , CASE WHEN up.gender = 1 THEN COALESCE(numberd_goal.goal_created_at3, 0) ELSE 0 END AS '夫が金融機関を目標貯金に連携した時刻３'

  , CASE WHEN up.gender = 0 THEN COALESCE(numberd_goal.goal_created_at1, 0) ELSE 0 END AS '妻が金融機関を目標貯金に連携した時刻１'
  , CASE WHEN up.gender = 0 THEN COALESCE(numberd_goal.goal_created_at2, 0) ELSE 0 END AS '妻が金融機関を目標貯金に連携した時刻２'
  , CASE WHEN up.gender = 0 THEN COALESCE(numberd_goal.goal_created_at3, 0) ELSE 0 END AS '妻が金融機関を目標貯金に連携した時刻３'

  , CASE WHEN up.gender IS NULL THEN COALESCE(numberd_goal.goal_created_at1, 0) ELSE 0 END AS '不明が金融機関を目標貯金に連携した時刻１'
  , CASE WHEN up.gender IS NULL THEN COALESCE(numberd_goal.goal_created_at2, 0) ELSE 0 END AS '不明が金融機関を目標貯金に連携した時刻２'
  , CASE WHEN up.gender IS NULL THEN COALESCE(numberd_goal.goal_created_at3, 0) ELSE 0 END AS '不明が金融機関を目標貯金に連携した時刻３'

  , CASE WHEN COALESCE(all_pg.count, 0) > 0 THEN 1 ELSE 0 END AS 'ペアリング経験有無'
  , COALESCE(all_pg.count, 0) AS 'ペアリング回数'
  , COALESCE(all_pg.min_created_at, 0) AS 'ペアリング完了日時（初回）'
  , COALESCE(all_pg.from_count, 0) AS 'ペアリング招待した回数'
  , COALESCE(all_pg.to_count, 0) AS 'ペアリング招待された回数'

  , CASE WHEN all_share_financial.count > 0 THEN 1 ELSE 0 END '金融機関の共有経験の有無'
  , CASE WHEN up.gender = 1 THEN COALESCE(all_share_financial.m_count, 0) ELSE 0 END '金融機関の総共有数＿夫が実施'
  , CASE WHEN up.gender = 0 THEN COALESCE(all_share_financial.f_count, 0) ELSE 0 END '金融機関の総共有数＿妻が実施'
  , CASE WHEN up.gender IS NULL THEN COALESCE(all_share_financial.n_count, 0) ELSE 0 END '金融機関の総共有数＿不明が実施'

  , CASE WHEN all_share_transactions.count > 0 THEN 1 ELSE 0 END AS '明細の共有経験の有無'
  , CASE WHEN up.gender = 1 THEN COALESCE(all_share_transactions.m_count, 0) ELSE 0 END AS '明細の総共有数＿夫が実施'
  , CASE WHEN up.gender = 0 THEN COALESCE(all_share_transactions.f_count, 0) ELSE 0 END AS '明細の総共有数＿妻が実施'
  , CASE WHEN up.gender IS NULL THEN COALESCE(all_share_transactions.n_count, 0) ELSE 0 END AS '明細の総共有数＿不明が実施'

  , COALESCE(all_goal.count, 0) AS '目標貯金総作成数'
FROM
  users u

LEFT JOIN
  -- プロフィール
  user_profiles up ON (up.user_id = u.id)

LEFT JOIN -- 診断タイプ(最大ステップ数の時のbudget_question_idで判別可能) と　Q3
  (
    SELECT
      max_step_teble.user_id
      , max_step_teble.budget_question_id
      , max_step_teble.max_step
      , CASE
        WHEN COALESCE(max_step_teble.budget_question_id, 0) = 5 THEN "貯金用の口座で2人で貯金"
        WHEN COALESCE(max_step_teble.budget_question_id, 0) = 6 THEN "家計用と同じ口座で2人で貯金"
        WHEN COALESCE(max_step_teble.budget_question_id, 0) = 7 THEN "それぞれが個人口座で貯金"
        WHEN COALESCE(max_step_teble.budget_question_id, 0) = 8 THEN "貯金用の口座で2人で貯金"
        WHEN COALESCE(max_step_teble.budget_question_id, 0) = 9 THEN "それぞれが個人口座で貯金"
        ELSE 0
      END Q3
    FROM
      (
        SELECT
          ubq.user_id
          , ubq.budget_question_id
          , max_step_teble.max_step
        FROM
          users u
        LEFT JOIN
          user_budget_questions ubq ON (ubq.user_id = u.id)
        LEFT JOIN
          (
            SELECT
              ubq.user_id
              , max(ubq.step) max_step
            FROM
              users u
            LEFT JOIN
              user_budget_questions ubq ON (ubq.user_id = u.id)
            GROUP BY
              ubq.user_id
          ) max_step_teble ON (max_step_teble.user_id = u.id)
        WHERE
          max_step_teble.max_step = ubq.step
      ) max_step_teble
  ) max_step_teble ON (max_step_teble.user_id = u.id)

LEFT JOIN -- 診断のQ1,Q2の回答用
  (
    SELECT
      q3.user_id
      ,  (
        SELECT
          CASE
            WHEN q3.budget_question_id = 3 THEN
              CASE
                WHEN prev_question_id = 2 THEN "2人が一定額を出しあい、そこから支出"
                ELSE "2人の収入をすべて合算し、そこから支出"
              END
            WHEN q3.budget_question_id = 4 THEN
              CASE
                WHEN prev_question_id = 2 THEN "2人が一定額を出しあい、そこから支出"
                ELSE "家賃・食費などの項目をそれぞれが担当し支出"
              END
            ELSE 0
          END
      ) Q1
      , (
        SELECT
          CASE
            WHEN q3.budget_question_id = 3 THEN
              CASE
                WHEN prev_question_id = 2 THEN "共用口座が有る"
                ELSE "スキップ"
              END
            WHEN q3.budget_question_id = 4 THEN
              CASE
                WHEN prev_question_id = 2 THEN "共用口座が無い"
                ELSE "スキップ"
              END
            ELSE 0
          END
      ) Q2
    FROM
      (
        SELECT
          tmp.user_id
          , step
          , budget_question_id
          ,(
            SELECT
              budget_question_id
            FROM
              user_budget_questions
            WHERE
              user_budget_questions.user_id = tmp.user_id
              AND user_budget_questions.step = tmp.step - 1 -- 1つ前のbudget_question_id
          ) prev_question_id
        FROM
          user_budget_questions tmp
        WHERE
          budget_question_id IN (3,4) -- Q3に限定するため、budget_question_idの3,4とする
          AND NOT EXISTS
          (
            SELECT
              1
            FROM
              user_budget_questions tmp2
            WHERE
              tmp.user_id = tmp2.user_id
              AND tmp.step < tmp2.step -- 前の選択肢に戻れる仕様を考慮
              AND tmp2.budget_question_id IN (3,4)
          )
      ) q3
  ) question ON (question.user_id = u.id)

LEFT JOIN -- 有効なペアリング
  (
  SELECT
    pg.user_id
    , pg.group_id
    , pg.from_user_id
    , pg.to_user_id
    , pg.created_at
  FROM
    ( -- 一人に複数グループが所属している場合、グループIDが小さいほうを取得する
      -- 実績として小さいグループIDのほうにデータが紐づいている
      SELECT
          pg.user_id
          , MIN(pg.group_id) group_id
          , pr.from_user_id
          , pr.to_user_id
          , MIN(pg.created_at) created_at
        FROM
          participate_groups pg
        INNER JOIN
          pairing_requests pr ON (pr.group_id = pg.group_id)
        WHERE
          pg.deleted_at IS NULL
        GROUP BY
          pg.user_id
      ) pg
    LEFT JOIN -- 有効なペアリングの招待情報
      pairing_requests pr ON (pr.group_id = pg.group_id)
  ) available_pg on (available_pg.user_id = u.id)

LEFT JOIN -- アカウントトラッカー
  (
    SELECT
      (id) id
      , au.user_id
    FROM
      at_users au
    WHERE
      au.deleted_at is null
    GROUP BY
      au.user_id
  ) au on (au.user_id = u.id)

LEFT JOIN -- 口座、カード、電子マネー
  (
    SELECT
      financial.at_user_id
      , CASE WHEN count(financial.at_user_id) > 0 THEN 1 ELSE 0 END is_connected
      , MIN(financial.created_at) min_created_at
      , COALESCE(SUM(CASE WHEN financial.type = 'bank' THEN 1 ELSE 0 END), 0) bank_count
      , COALESCE(SUM(CASE WHEN financial.type = 'card' THEN 1 ELSE 0 END), 0) card_count
      , COALESCE(SUM(CASE WHEN financial.type = 'emoney' THEN 1 ELSE 0 END), 0) emoney_count
    FROM
      (
        SELECT
          auba.at_user_id
          , auba.created_at
          , 'bank' type
        FROM
          at_user_bank_accounts auba
        WHERE
          auba.deleted_at IS NULL

        UNION ALL

        SELECT
          auca.at_user_id
          , auca.created_at
          , 'card' type
        FROM
          at_user_card_accounts auca
        WHERE
          auca.deleted_at IS NULL

        UNION ALL

        SELECT
          auea.at_user_id
          , auea.created_at
          , 'emoney' type
        FROM
          at_user_emoney_service_accounts auea
        WHERE
          auea.deleted_at IS NULL

      ) financial
    GROUP BY
      financial.at_user_id
  ) financial on (financial.at_user_id = au.id)

LEFT JOIN -- 口座名
  (
    SELECT
      au.id at_user_id
      -- at_users.id で GROUP BY し、集約関数で銀行名を連結する
      -- 集約値に、 bank_number ごとに変化する値を指定することで
      -- 特定の bank_number のデータのみが残る
      , GROUP_CONCAT(CASE WHEN numbered_bank.bank_number = 1 THEN numbered_bank.fnc_nm ELSE NULL END) AS bank1
      , GROUP_CONCAT(CASE WHEN numbered_bank.bank_number = 2 THEN numbered_bank.fnc_nm ELSE NULL END) AS bank2
      , GROUP_CONCAT(CASE WHEN numbered_bank.bank_number = 3 THEN numbered_bank.fnc_nm ELSE NULL END) AS bank3
      , GROUP_CONCAT(CASE WHEN numbered_bank.bank_number = 4 THEN numbered_bank.fnc_nm ELSE NULL END) AS bank4
      , GROUP_CONCAT(CASE WHEN numbered_bank.bank_number = 5 THEN numbered_bank.fnc_nm ELSE NULL END) AS bank5
    FROM
      at_users au
    LEFT JOIN
      (
        SELECT
          auba.at_user_id
          , auba.fnc_nm
          , ( -- サブクエリで銀行に連番を振る
            SELECT
              COUNT(*)+1
            FROM
              at_user_bank_accounts t
            WHERE -- at_user_card_accounts 内で at_user が同一で、id が違うものをカウント ＝ at_user ごとに連番が振られる
              t.id < auba.id
              AND t.at_user_id = auba.at_user_id
              AND t.deleted_at is null
          ) bank_number
        FROM
          at_user_bank_accounts auba
        where
          auba.deleted_at IS NULL
      ) numbered_bank ON (numbered_bank.at_user_id = au.id)
    GROUP BY
      au.id
  ) numbered_bank ON (numbered_bank.at_user_id = au.id)

LEFT JOIN -- カード名
  (
    SELECT
      au.id at_user_id
      -- at_users.id で GROUP BY し、集約関数でカード名を連結する
      -- 集約値に、 bank_number ごとに変化する値を指定することで
      -- 特定の bank_number のデータのみが残る
      , GROUP_CONCAT(CASE WHEN numbered_card.card_number = 1 THEN numbered_card.fnc_nm ELSE NULL END) AS card1
      , GROUP_CONCAT(CASE WHEN numbered_card.card_number = 2 THEN numbered_card.fnc_nm ELSE NULL END) AS card2
      , GROUP_CONCAT(CASE WHEN numbered_card.card_number = 3 THEN numbered_card.fnc_nm ELSE NULL END) AS card3
      , GROUP_CONCAT(CASE WHEN numbered_card.card_number = 4 THEN numbered_card.fnc_nm ELSE NULL END) AS card4
      , GROUP_CONCAT(CASE WHEN numbered_card.card_number = 5 THEN numbered_card.fnc_nm ELSE NULL END) AS card5
    FROM
      at_users au
    LEFT JOIN
      (
        SELECT
          auca.at_user_id
          , auca.fnc_nm
          , ( -- サブクエリで銀行に連番を振る
            SELECT
              COUNT(*)+1
            FROM
              at_user_card_accounts t
            WHERE -- at_user_card_accounts 内で at_user が同一で、id が違うものをカウント ＝ at_user ごとに連番が振られる
              t.id < auca.id
              AND t.at_user_id = auca.at_user_id
              AND t.deleted_at is null
          ) card_number
        FROM
          at_user_card_accounts auca
        where
          auca.deleted_at IS NULL
      ) numbered_card ON (numbered_card.at_user_id = au.id)
    GROUP BY
      au.id
  ) numbered_card ON (numbered_card.at_user_id = au.id)

LEFT JOIN -- 電子マネー名
  (
    SELECT
      au.id at_user_id
      -- at_users.id で GROUP BY し、集約関数で電子マネー名を連結する
      -- 集約値に、 bank_number ごとに変化する値を指定することで
      -- 特定の bank_number のデータのみが残る
      , GROUP_CONCAT(CASE WHEN numbered_emoney.emoney_number = 1 THEN numbered_emoney.fnc_nm ELSE NULL END) AS emoney1
      , GROUP_CONCAT(CASE WHEN numbered_emoney.emoney_number = 2 THEN numbered_emoney.fnc_nm ELSE NULL END) AS emoney2
      , GROUP_CONCAT(CASE WHEN numbered_emoney.emoney_number = 3 THEN numbered_emoney.fnc_nm ELSE NULL END) AS emoney3
      , GROUP_CONCAT(CASE WHEN numbered_emoney.emoney_number = 4 THEN numbered_emoney.fnc_nm ELSE NULL END) AS emoney4
      , GROUP_CONCAT(CASE WHEN numbered_emoney.emoney_number = 5 THEN numbered_emoney.fnc_nm ELSE NULL END) AS emoney5
    FROM
      at_users au
    LEFT JOIN
      (
        SELECT
          auea.at_user_id
          , auea.fnc_nm
          , ( -- サブクエリで銀行に連番を振る
            SELECT
              COUNT(*)+1
            FROM
              at_user_emoney_service_accounts t
            WHERE -- at_user_emoney_service_accounts 内で at_user が同一で、id が違うものをカウント ＝ at_user ごとに連番が振られる
              t.id < auea.id
              AND t.at_user_id = auea.at_user_id
              AND t.deleted_at is null
          ) emoney_number
        FROM
          at_user_emoney_service_accounts auea
        where
          auea.deleted_at IS NULL
      ) numbered_emoney ON (numbered_emoney.at_user_id = au.id)
    GROUP BY
      au.id
  ) numbered_emoney ON (numbered_emoney.at_user_id = au.id)

LEFT JOIN -- 口座、カード、電子マネー(削除含む)
  (
    SELECT
      financial.at_user_id
      , CASE WHEN count(financial.at_user_id) > 0 THEN 1 ELSE 0 END is_connected
      , COALESCE(SUM(CASE WHEN financial.type = 'bank' THEN 1 ELSE 0 END), 0) bank_count
      , COALESCE(SUM(CASE WHEN financial.type = 'card' THEN 1 ELSE 0 END), 0) card_count
      , COALESCE(SUM(CASE WHEN financial.type = 'emoney' THEN 1 ELSE 0 END), 0) emoney_count
    FROM
      (
        SELECT
          auba.at_user_id
          , 'bank' type
        FROM
          at_user_bank_accounts auba

        UNION ALL

        SELECT
          auca.at_user_id
          , 'card' type
        FROM
          at_user_card_accounts auca

        UNION ALL

        SELECT
          auea.at_user_id
          , 'emoney' type
        FROM
          at_user_emoney_service_accounts auea

      ) financial
    GROUP BY
      financial.at_user_id
  ) all_financial on (all_financial.at_user_id = au.id)

LEFT JOIN -- ペアリングされた金融機関情報（グループで取得）
  (
    SELECT
      financial.group_id
      , COUNT(financial.group_id) count
    FROM
      (
        SELECT
          auba.at_user_id
          ,auba.group_id
        FROM
          at_user_bank_accounts auba
        WHERE
          auba.share = true
          AND auba.group_id IS NOT NULL
          AND auba.deleted_at IS NULL

        UNION ALL

        SELECT
          auca.at_user_id
          ,auca.group_id
        FROM
          at_user_card_accounts auca
        WHERE
          auca.share = true
          AND auca.group_id IS NOT NULL
          AND auca.deleted_at IS NULL

        UNION ALL

        SELECT
          auesa.at_user_id
          ,auesa.group_id
        FROM
          at_user_emoney_service_accounts auesa
        WHERE
          auesa.share = true
          AND auesa.group_id IS NOT NULL
          AND auesa.deleted_at IS NULL
      ) financial
    GROUP BY
      financial.group_id
  ) share_financial_g ON (share_financial_g.group_id = available_pg.group_id)

LEFT JOIN -- 個人からペアリングされた明細情報（グループで取得）
  (
    SELECT
      udt.group_id
      , COUNT(udt.group_id) count
    FROM
      user_distributed_transactions udt
    LEFT JOIN -- 夫、妻、不明判定用
      user_profiles up ON up.user_id = udt.user_id

    LEFT JOIN -- 銀行
      at_user_bank_transactions aubt ON aubt.id = udt.at_user_bank_transaction_id
    LEFT JOIN
      at_user_bank_accounts auba ON auba.id = aubt.at_user_bank_account_id AND auba.deleted_at IS NULL

    LEFT JOIN -- カード
      at_user_card_transactions auct ON auct.id = udt.at_user_card_transaction_id
    LEFT JOIN
      at_user_card_accounts auca ON auca.id = auct.at_user_card_account_id AND auca.deleted_at IS NULL

    LEFT JOIN -- 電子マネー
      at_user_emoney_transactions auet ON auet.id = udt.at_user_emoney_transaction_id
    LEFT JOIN
      at_user_emoney_service_accounts auea ON auea.id = auet.at_user_emoney_service_account_id AND auea.deleted_at IS NULL

    WHERE
      udt.share = true
      AND udt.group_id IS NOT NULL
    GROUP BY
      udt.group_id
  ) share_transactions_g ON (share_transactions_g.group_id = available_pg.group_id)

LEFT JOIN -- ペアリングされた金融機関情報
  (
    SELECT
      financial.at_user_id
      , SUM(CASE WHEN up.gender = 1 THEN 1 ELSE 0 END) m_count
      , SUM(CASE WHEN up.gender = 0 THEN 1 ELSE 0 END) f_count
      , SUM(CASE WHEN up.gender IS NULL THEN 1 ELSE 0 END) n_count
    FROM
      (
        SELECT
          auba.at_user_id
          ,auba.group_id
        FROM
          at_user_bank_accounts auba
        WHERE
          auba.share = true
          AND auba.group_id IS NOT NULL
          AND auba.deleted_at IS NULL

        UNION ALL

        SELECT
          auca.at_user_id
          ,auca.group_id
        FROM
          at_user_card_accounts auca
        WHERE
          auca.share = true
          AND auca.group_id IS NOT NULL
          AND auca.deleted_at IS NULL

        UNION ALL

        SELECT
          auesa.at_user_id
          ,auesa.group_id
        FROM
          at_user_emoney_service_accounts auesa
        WHERE
          auesa.share = true
          AND auesa.group_id IS NOT NULL
          AND auesa.deleted_at IS NULL
      ) financial
    LEFT JOIN
      at_users au ON (au.id = financial.at_user_id)
    LEFT JOIN
      user_profiles up ON (up.user_id = au.user_id)
    GROUP BY
      financial.at_user_id
  ) share_financial ON (share_financial.at_user_id = au.id)

LEFT JOIN -- 個人からペアリングされた明細情報
  (
    SELECT
      udt.user_id
      ,SUM(CASE WHEN up.gender = 1 THEN 1 ELSE 0 END) AS m_count
      ,MIN(CASE WHEN up.gender = 1 THEN up.created_at ELSE 0 END) as m_created_at
      ,SUM(CASE WHEN up.gender = 0 THEN 1 ELSE 0 END) AS f_count
      ,MIN(CASE WHEN up.gender = 0 THEN up.created_at ELSE 0 END) as f_created_at
      ,SUM(CASE WHEN up.gender IS NULL THEN 1 ELSE 0 END) AS n_count
      ,MIN(CASE WHEN up.gender IS NULL THEN up.created_at ELSE 0 END) as n_created_at
    FROM
      user_distributed_transactions udt
    LEFT JOIN -- 夫、妻、不明判定用
      user_profiles up ON up.user_id = udt.user_id

    LEFT JOIN -- 銀行
      at_user_bank_transactions aubt ON aubt.id = udt.at_user_bank_transaction_id
    LEFT JOIN
      at_user_bank_accounts auba ON auba.id = aubt.at_user_bank_account_id AND auba.deleted_at IS NULL

    LEFT JOIN -- カード
      at_user_card_transactions auct ON auct.id = udt.at_user_card_transaction_id
    LEFT JOIN
      at_user_card_accounts auca ON auca.id = auct.at_user_card_account_id AND auca.deleted_at IS NULL

    LEFT JOIN -- 電子マネー
      at_user_emoney_transactions auet ON auet.id = udt.at_user_emoney_transaction_id
    LEFT JOIN
      at_user_emoney_service_accounts auea ON auea.id = auet.at_user_emoney_service_account_id AND auea.deleted_at IS NULL

    WHERE
      udt.share = true
      AND udt.group_id IS NOT NULL
    GROUP BY
      udt.user_id
  ) share_transactions ON (share_transactions.user_id = u.id)

LEFT JOIN -- 目標情報（グループで取得）
  (
    SELECT
      g.group_id
      , COUNT(g.group_id) count
    FROM
      goals g
    WHERE
      g.deleted_at IS NULL
    GROUP BY
      g.group_id
  ) goal_g ON (goal_g.group_id = available_pg.group_id)

LEFT JOIN -- 目標情報
  (
    SELECT
      g.user_id
      ,count(g.user_id) AS count
      ,SUM(CASE WHEN g.goal_type_id = 1 THEN 1 ELSE 0 END) AS house -- 住宅購入/頭金
      ,SUM(CASE WHEN g.goal_type_id = 2 THEN 1 ELSE 0 END) AS child -- 子供教育資金
      ,SUM(CASE WHEN g.goal_type_id = 3 THEN 1 ELSE 0 END) AS weding -- 結婚/旅行
      ,SUM(CASE WHEN g.goal_type_id = 4 THEN 1 ELSE 0 END) AS for_now -- とりあえず貯金
      ,SUM(CASE WHEN g.goal_type_id = 5 THEN 1 ELSE 0 END) AS old_age -- 老後資金
      ,SUM(CASE WHEN g.goal_type_id = 6 THEN 1 ELSE 0 END) AS re_pay -- 繰り上げ返済
      ,SUM(CASE WHEN g.goal_type_id = 7 THEN 1 ELSE 0 END) AS car -- 車/バイク
      ,SUM(CASE WHEN g.goal_type_id = 8 THEN 1 ELSE 0 END) AS other -- その他
    FROM
      goals g
    WHERE
      g.deleted_at IS NULL
    GROUP BY
      g.user_id
  ) AS goal ON goal.user_id = u.id

LEFT JOIN -- 金融機関を目標貯金に連携した時刻
  (
    SELECT
      users.id
      , max(CASE WHEN numberd_goal.goal_number = 1 THEN numberd_goal.created_at ELSE NULL END) AS goal_created_at1
      , max(CASE WHEN numberd_goal.goal_number = 2 THEN numberd_goal.created_at ELSE NULL END) AS goal_created_at2
      , max(CASE WHEN numberd_goal.goal_number = 3 THEN numberd_goal.created_at ELSE NULL END) AS goal_created_at3
    FROM
      users
    LEFT JOIN
    (
      SELECT
        goal_settings.user_id
        , goal_settings.created_at
        , (
          SELECT
            -- at_user_bank_account_id が NULLならカウントもNULLとする
            CASE WHEN goal_settings.at_user_bank_account_id IS NULL THEN NULL ELSE COUNT(*)+1 END AS bank_number
          FROM
            (
              SELECT
                gs.id
                , gs.user_id
              FROM
                goal_settings gs
              LEFT JOIN
                goals g on (g.id = gs.goal_id)
              WHERE
                gs.at_user_bank_account_id IS NOT NULL -- at_user_bank_account_id が NULLを除いて連番を振る
                AND g.deleted_at IS NULL
            ) as t
          WHERE
            t.id < goal_settings.id -- 連番にするため、id同士で比較してカウントする
            AND t.user_id = goal_settings.user_id -- user_id でグルーピングされた連番とする
          ) AS goal_number
        FROM
          goal_settings
        LEFT JOIN
          goals on (goals.id = goal_settings.goal_id)
        WHERE
          goals.deleted_at IS NULL
    ) numberd_goal ON numberd_goal.user_id = users.id
  GROUP BY
    users.id
  ) numberd_goal ON numberd_goal.id = u.id

LEFT JOIN -- ペアリング経験（削除含む）
  (
    SELECT
      pg.user_id
      , count(pg.user_id) count
      , MIN(pg.created_at) min_created_at
      , SUM(CASE WHEN pr.from_user_id = pg.user_id THEN 1 ELSE 0 END) from_count
      , SUM(CASE WHEN pr.to_user_id = pg.user_id THEN 1 ELSE 0 END) to_count
    FROM
      participate_groups pg
    LEFT JOIN
      pairing_requests pr ON (pr.group_id = pg.group_id)
    GROUP BY
      pg.user_id
  ) all_pg ON (all_pg.user_id = u.id)

LEFT JOIN -- ペアリングされた金融機関情報（削除含む）
  (
    SELECT
      financial.at_user_id
      , SUM(CASE WHEN up.gender = 1 THEN 1 ELSE 0 END) m_count
      , SUM(CASE WHEN up.gender = 0 THEN 1 ELSE 0 END) f_count
      , SUM(CASE WHEN up.gender IS NULL THEN 1 ELSE 0 END) n_count
      , count(financial.at_user_id) count
    FROM
      (
        SELECT
          auba.at_user_id
          ,auba.group_id
        FROM
          at_user_bank_accounts auba
        WHERE
          auba.share = true
          AND auba.group_id IS NOT NULL

        UNION ALL

        SELECT
          auca.at_user_id
          ,auca.group_id
        FROM
          at_user_card_accounts auca
        WHERE
          auca.share = true
          AND auca.group_id IS NOT NULL

        UNION ALL

        SELECT
          auesa.at_user_id
          ,auesa.group_id
        FROM
          at_user_emoney_service_accounts auesa
        WHERE
          auesa.share = true
          AND auesa.group_id IS NOT NULL
      ) financial
    LEFT JOIN
      at_users au ON (au.id = financial.at_user_id)
    LEFT JOIN
      user_profiles up ON (up.user_id = au.user_id)
    GROUP BY
      financial.at_user_id
  ) all_share_financial ON (all_share_financial.at_user_id = au.id)

LEFT JOIN -- 個人からペアリングされた明細情報（削除含む）
  (
    SELECT
      udt.user_id
      ,SUM(CASE WHEN up.gender = 1 THEN 1 ELSE 0 END) AS m_count
      ,MIN(CASE WHEN up.gender = 1 THEN up.created_at ELSE 0 END) as m_created_at
      ,SUM(CASE WHEN up.gender = 0 THEN 1 ELSE 0 END) AS f_count
      ,MIN(CASE WHEN up.gender = 0 THEN up.created_at ELSE 0 END) as f_created_at
      ,SUM(CASE WHEN up.gender IS NULL THEN 1 ELSE 0 END) AS n_count
      ,MIN(CASE WHEN up.gender IS NULL THEN up.created_at ELSE 0 END) as n_created_at
      , count(udt.user_id) count
    FROM
      user_distributed_transactions udt
    LEFT JOIN -- 夫、妻、不明判定用
      user_profiles up ON up.user_id = udt.user_id

    LEFT JOIN -- 銀行
      at_user_bank_transactions aubt ON aubt.id = udt.at_user_bank_transaction_id
    LEFT JOIN
      at_user_bank_accounts auba ON auba.id = aubt.at_user_bank_account_id

    LEFT JOIN -- カード
      at_user_card_transactions auct ON auct.id = udt.at_user_card_transaction_id
    LEFT JOIN
      at_user_card_accounts auca ON auca.id = auct.at_user_card_account_id

    LEFT JOIN -- 電子マネー
      at_user_emoney_transactions auet ON auet.id = udt.at_user_emoney_transaction_id
    LEFT JOIN
      at_user_emoney_service_accounts auea ON auea.id = auet.at_user_emoney_service_account_id

    WHERE
      udt.share = true
      AND udt.group_id IS NOT NULL
    GROUP BY
      udt.user_id
  ) all_share_transactions ON (all_share_transactions.user_id = u.id)

LEFT JOIN -- 目標情報（削除含む取得）
  (
    SELECT
      g.user_id
      , COUNT(g.user_id) count
    FROM
      goals g
    GROUP BY
      g.user_id
  ) all_goal ON (all_goal.user_id = u.id)

ORDER BY
  u.id
;
