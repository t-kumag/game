SELECT 
  u.id AS ユーザID,

  CASE
    WHEN pg.group_id IS NULL THEN 0
    ELSE pg.group_id
  END AS ペアリングID, -- 初回のペアリングID（ペアリング解除済みを考慮しない）

  u.created_at AS メール登録完了日時, -- 仮登録日時
  
  email_authenticated AS メアド認証,　-- 本登録の有無
  
  u.email AS メールアドレス,
  
  CASE
    WHEN u.deleted_at IS NULL THEN 0
    ELSE 1
  END AS 退会の有無,

  CASE
    WHEN gender = 0 THEN "女" 
    WHEN gender = 1 THEN "男" 
    ELSE 0
  END AS 性別,

  COALESCE(birthday, 0) AS 生年月日,

  CASE 
    WHEN has_child > 0 THEN 1
    ELSE 0
  END AS 子どもの有無,


  push AS push許諾,


  COALESCE(max_step_teble.budget_question_id, 0) AS 診断タイプ,
  
    (
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
  ) AS Q1,

  (
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
  ) as Q2,
  
  CASE 
    WHEN COALESCE(max_step_teble.budget_question_id, 0) = 5 THEN "貯金用の口座で2人で貯金"
    WHEN COALESCE(max_step_teble.budget_question_id, 0) = 6 THEN "家計用と同じ口座で2人で貯金"
    WHEN COALESCE(max_step_teble.budget_question_id, 0) = 7 THEN "それぞれが個人口座で貯金"
    WHEN COALESCE(max_step_teble.budget_question_id, 0) = 8 THEN "貯金用の口座で2人で貯金"
    WHEN COALESCE(max_step_teble.budget_question_id, 0) = 9 THEN "それぞれが個人口座で貯金"
    ELSE 0
  END AS Q3,


  CASE
    WHEN COALESCE((
      SELECT
        COUNT(*)
      FROM
        at_user_bank_accounts AS tmp
      WHERE
        tmp.at_user_id = au.id
      GROUP BY
        tmp.at_user_id
    ), 0)
    +
    COALESCE((
      SELECT
        COUNT(*)
      FROM
        at_user_card_accounts AS tmp
      WHERE
        tmp.at_user_id = au.id
      GROUP BY
        tmp.at_user_id
    ), 0)
    +
    COALESCE((
      SELECT
        COUNT(*)
      FROM
        at_user_emoney_service_accounts AS tmp
      WHERE
        tmp.at_user_id = au.id
      GROUP BY
        tmp.at_user_id
    ),0) > 0 THEN 1
    ELSE 0
  END AS 口座連携の有無,



  COALESCE(first_created_accounts.created_at, 0) AS "口座連携の日時(初回連携分)",


  COALESCE((
    SELECT
      COUNT(*)
    FROM
      at_user_bank_accounts AS tmp
    WHERE
      tmp.at_user_id = au.id
    GROUP BY
      tmp.at_user_id
  ), 0) AS 口座連携数_銀行,


  COALESCE((
    SELECT
      COUNT(*)
    FROM
      at_user_card_accounts AS tmp
    WHERE
      tmp.at_user_id = au.id
    GROUP BY
      tmp.at_user_id
  ), 0) AS 口座連携数_カード,


  COALESCE((
    SELECT
      COUNT(*)
    FROM
      at_user_emoney_service_accounts AS tmp
    WHERE
      tmp.at_user_id = au.id
    GROUP BY
      tmp.at_user_id
  ),0) AS 口座連携数_電子マネー,

  -- ユーザーの連携銀行名、ない場合はnull
  at_user_numbered_bank.口座１,
  at_user_numbered_bank.口座２,
  at_user_numbered_bank.口座３,
  at_user_numbered_bank.口座４,
  at_user_numbered_bank.口座５,

  -- ユーザーの連携カード名1～5、ない場合はnull
  at_user_numbered_card.クレカ１,
  at_user_numbered_card.クレカ２,
  at_user_numbered_card.クレカ３,
  at_user_numbered_card.クレカ４,
  at_user_numbered_card.クレカ５,

  -- ユーザーの連携電子マネー名1～5、ない場合はnull
  at_user_numbered_emoney.IC１,
  at_user_numbered_emoney.IC２,
  at_user_numbered_emoney.IC３,
  at_user_numbered_emoney.IC４,
  at_user_numbered_emoney.IC５,



  CASE 
    WHEN pg.group_id IS NULL THEN 0
    ELSE 1
  END AS ペアリング有無, -- ペアリング解除済みの場合でもペアリング有（ペアリング解除済みを考慮しない）


  CASE 
    WHEN pg.user_id IS NULL THEN 0 
    ELSE pg.created_at 
  END AS ペアリング完了日時, -- 初回のぺアリング完了日時（ペアリング解除済みを考慮しない）


  CASE 
    WHEN gender = 1 THEN
      COALESCE((
        SELECT
          COUNT(*)
        FROM
          at_user_bank_accounts
        WHERE
          at_user_id = au.id
          AND share = true
        GROUP BY
          u.id
      ), 0)
      +
      COALESCE((
        SELECT
          COUNT(*)
        FROM
          at_user_card_accounts
        WHERE
          at_user_id = au.id
          AND share = true
        GROUP BY
          u.id
      ), 0)
      +
      COALESCE((
        SELECT
          COUNT(*)
        FROM
          at_user_emoney_service_accounts
        WHERE
          at_user_id = au.id
          AND share = true
        GROUP BY
          u.id
      ), 0)
    ELSE 0
  END AS 金融機関の共有数＿夫が実施,


  CASE 
    WHEN gender = 0 THEN
      COALESCE((
        SELECT
          COUNT(*)
        FROM
          at_user_bank_accounts
        WHERE
          at_user_id = au.id
          AND share = true
        GROUP BY
          u.id
      ), 0)
      +
      COALESCE((
        SELECT
          COUNT(*)
        FROM
          at_user_card_accounts
        WHERE
          at_user_id = au.id
          AND share = true
        GROUP BY
          u.id
      ), 0)
      +
      COALESCE((
        SELECT
          COUNT(*)
        FROM
          at_user_emoney_service_accounts
        WHERE
          at_user_id = au.id
          AND share = true
        GROUP BY
          u.id
      ), 0)
    ELSE 0
  END AS 金融機関の共有数＿妻が実施,


  CASE
    WHEN gender IS NULL THEN
      COALESCE((
        SELECT
          COUNT(*)
        FROM
          at_user_bank_accounts
        WHERE
          at_user_id = au.id
          AND share = true
        GROUP BY
          u.id
      ), 0)
      +
      COALESCE((
        SELECT
          COUNT(*)
        FROM
          at_user_card_accounts
        WHERE
          at_user_id = au.id
          AND share = true
        GROUP BY
          u.id
      ), 0)
      +
      COALESCE((
        SELECT
          COUNT(*)
        FROM
          at_user_emoney_service_accounts
        WHERE
          at_user_id = au.id
          AND share = true
        GROUP BY
          u.id
      ), 0)
    ELSE 0
  END AS 金融機関の共有数＿不明が実施,


  CASE 
    WHEN gender = 1 THEN
      COALESCE((
        SELECT
          COUNT(*)
        FROM
          user_distributed_transactions
        WHERE
          user_id = u.id
          AND share = true
        GROUP BY
          u.id
      ), 0)
    ELSE 0
  END AS 明細の共有数＿夫が実施,

  CASE
    WHEN gender = 1 THEN
      COALESCE((
       SELECT
         min(udt.created_at) AS first_sharing_time
       FROM
         user_distributed_transactions AS udt
       WHERE
         udt.user_id = u.id
         AND udt.share = true
       GROUP BY
         user_id
     ), 0)
    ELSE 0
  END AS "明細の共有日時＿夫が実施(個人→夫婦)(初回実施分)",


  CASE
    WHEN gender = 0 THEN
      COALESCE((
       SELECT
         min(udt.created_at) AS first_sharing_time
       FROM
         user_distributed_transactions AS udt
       WHERE
         udt.user_id = u.id
         AND udt.share = true
       GROUP BY
         user_id
     ), 0)
    ELSE 0
  END AS "明細の共有日時＿妻が実施(個人→夫婦)(初回実施分)",


  CASE
    WHEN gender IS NULL THEN
      COALESCE((
       SELECT
         min(udt.created_at) AS first_sharing_time
       FROM
         user_distributed_transactions AS udt
       WHERE
         udt.user_id = u.id
         AND udt.share = true
       GROUP BY
         user_id
     ), 0)
    ELSE 0
  END AS "明細の共有日時＿不明が実施(個人→夫婦)(初回実施分)",



  CASE
    WHEN gender = 0 THEN
      COALESCE((
        SELECT
          COUNT(*)
        FROM
          user_distributed_transactions
        WHERE
          user_id = u.id
          AND share = true
        GROUP BY
          u.id
      ), 0) 
    ELSE 0
  END AS 明細の共有数＿妻が実施,


  CASE
    WHEN gender IS NULL THEN 
      COALESCE((
        SELECT
          COUNT(*)
        FROM
          user_distributed_transactions
        WHERE
          user_id = u.id
          AND share = true
        GROUP BY
          u.id
      ), 0)
    ELSE 0
  END AS 明細の共有数＿不明が実施,


  CASE
    WHEN g.u IS NULL THEN 0
    ELSE g.u
  END AS 目標貯金作成数,


  CASE
    WHEN g.created_at IS NULL THEN 0
    ELSE g.created_at
  END AS 目標貯金作成日時,


  CASE
    WHEN exists 
      (
        SELECT
          *
        FROM
          goals AS g
        WHERE
          u.id = g.user_id
          AND goal_type_id = 1
      ) THEN 1
    ELSE 0
  END AS "住宅購入/頭金",


  CASE
    WHEN exists 
      (
        SELECT
          *
        FROM
          goals AS g
        WHERE
          u.id = g.user_id
          AND goal_type_id = 2
      ) THEN 1
    ELSE 0
  END AS "子供教育資金",


  CASE
    WHEN exists
      (
        SELECT
          *
        FROM
          goals AS g
        WHERE
          u.id = g.user_id
          AND goal_type_id = 3
      ) THEN 1
    ELSE 0
  END AS "結婚/旅行",


  CASE
    WHEN exists
      (
        SELECT
          *
        FROM
          goals AS g
        WHERE
          u.id = g.user_id
          AND goal_type_id = 4
      ) THEN 1
    ELSE 0
  END AS "とりあえず貯金",


  CASE
    WHEN exists
      (
        SELECT
          *
        FROM
          goals AS g
        WHERE
          u.id = g.user_id
          AND goal_type_id = 5
      ) THEN 1
    ELSE 0
  END AS "老後資金",


  CASE
    WHEN exists
      (
        SELECT
          *
        FROM
          goals AS g
        WHERE
          u.id = g.user_id
          AND goal_type_id = 6
      ) THEN 1
    ELSE 0
  END AS "繰り上げ返済",


  CASE
    WHEN exists
      (
        SELECT
          *
        FROM
          goals AS g
        WHERE
          u.id = g.user_id
          AND  goal_type_id = 7
      ) THEN 1
    ELSE 0
  END AS "車/バイク",


  CASE
    WHEN exists
      (
        SELECT
          *
        FROM
          goals AS g
        WHERE
          u.id = g.user_id
          AND goal_type_id = 8
      ) THEN 1
    ELSE 0
  END AS "その他",


  CASE
    WHEN gender = 1 THEN COALESCE(numbered_goal_settings_at_user_bank_account.金融機関を目標貯金に連携した時刻１, 0)
    ELSE 0
  END AS 夫が金融機関を目標貯金に連携した時刻１,
  
  CASE
    WHEN gender = 1 THEN COALESCE(numbered_goal_settings_at_user_bank_account.金融機関を目標貯金に連携した時刻２, 0)
    ELSE 0
  END AS 夫が金融機関を目標貯金に連携した時刻２,

  CASE
    WHEN gender = 1 THEN COALESCE(numbered_goal_settings_at_user_bank_account.金融機関を目標貯金に連携した時刻３, 0)
    ELSE 0
  END AS 夫が金融機関を目標貯金に連携した時刻３,


  CASE
    WHEN gender = 0 THEN COALESCE(numbered_goal_settings_at_user_bank_account.金融機関を目標貯金に連携した時刻１, 0)
    ELSE 0
  END AS 妻が金融機関を目標貯金に連携した時刻１,
  
  CASE
    WHEN gender = 0 THEN COALESCE(numbered_goal_settings_at_user_bank_account.金融機関を目標貯金に連携した時刻２, 0)
    ELSE 0
  END AS 妻が金融機関を目標貯金に連携した時刻２,

  CASE
    WHEN gender = 0 THEN COALESCE(numbered_goal_settings_at_user_bank_account.金融機関を目標貯金に連携した時刻３, 0)
    ELSE 0
  END AS 妻が金融機関を目標貯金に連携した時刻３,


  CASE
    WHEN gender IS NULL THEN COALESCE(numbered_goal_settings_at_user_bank_account.金融機関を目標貯金に連携した時刻１, 0)
    ELSE 0
  END AS 不明が金融機関を目標貯金に連携した時刻１,
  
  CASE
    WHEN gender IS NULL THEN COALESCE(numbered_goal_settings_at_user_bank_account.金融機関を目標貯金に連携した時刻２, 0)
    ELSE 0
  END AS 不明が金融機関を目標貯金に連携した時刻２,

  CASE
    WHEN gender IS NULL THEN COALESCE(numbered_goal_settings_at_user_bank_account.金融機関を目標貯金に連携した時刻３, 0)
    ELSE 0
  END AS 不明が金融機関を目標貯金に連携した時刻３


FROM -- ユーザID,メール登録完了日時,メアド認証,メールアドレス,退会の有無
  users AS u

INNER JOIN -- 性別,生年月日,子どもの有無,push許諾
  user_profiles AS up
ON 
  up.user_id = u.id 

LEFT JOIN -- 後続処理用
  at_users AS au
ON 
  u.id = au.user_id

LEFT JOIN -- ペアリングID,ペアリング有無,初回ペアリング日時
  (
    SELECT
      user_id,
      created_at,
      group_id
    FROM
      participate_groups 
    GROUP BY
      user_id
  ) AS pg
ON 
  pg.user_id = u.id

LEFT JOIN -- 目標貯金作成数,目標貯金作成日時,目標種類判断
  (
    SELECT
      user_id,
      created_at,
      count(user_id) AS u
    FROM
      goals 
    GROUP BY
      user_id
  ) AS g
ON g.user_id = u.id

LEFT JOIN -- 口座連携の日時(初回連携分)
 -- 各種連携機関（銀行,クレカ,電子マネー）のテーブルを結合（重複削除）しています。
  (
    SELECT
      union_table.at_user_id,
      union_table.created_at
    FROM
  (
    (
      SELECT
        at_user_bank_accounts.at_user_id,
        at_user_bank_accounts.fnc_nm,
        at_user_bank_accounts.created_at
      FROM
        at_user_bank_accounts
    )
    UNION
    (
      SELECT
        at_user_card_accounts.at_user_id,
        at_user_card_accounts.fnc_nm,
        at_user_card_accounts.created_at
      FROM
        at_user_card_accounts
    )
    UNION
    (
      SELECT
        at_user_emoney_service_accounts.at_user_id,
        at_user_emoney_service_accounts.fnc_nm,
        at_user_emoney_service_accounts.created_at
      FROM
        at_user_emoney_service_accounts
    )
  ) AS union_table
  GROUP BY
    at_user_id
) AS first_created_accounts
ON 
  first_created_accounts.at_user_id = au.id

LEFT JOIN -- 連携銀行名
  (
    SELECT
      users.id as user_id,
      -- at_users.id で GROUP BY し、集約関数で銀行名を連結する
      -- 集約値に、 bank_number ごとに変化する値を指定することで
      -- 特定の bank_number のデータのみが残る 
      GROUP_CONCAT(CASE WHEN at_user_numbered_bank.bank_number = 1 THEN at_user_numbered_bank.fnc_nm ELSE NULL END) AS 口座１,
      GROUP_CONCAT(CASE WHEN at_user_numbered_bank.bank_number = 2 THEN at_user_numbered_bank.fnc_nm ELSE NULL END) AS 口座２,
      GROUP_CONCAT(CASE WHEN at_user_numbered_bank.bank_number = 3 THEN at_user_numbered_bank.fnc_nm ELSE NULL END) AS 口座３,
      GROUP_CONCAT(CASE WHEN at_user_numbered_bank.bank_number = 4 THEN at_user_numbered_bank.fnc_nm ELSE NULL END) AS 口座４,
      GROUP_CONCAT(CASE WHEN at_user_numbered_bank.bank_number = 5 THEN at_user_numbered_bank.fnc_nm ELSE NULL END) AS 口座５
    FROM
      users
    LEFT JOIN
      at_users
    ON
      at_users.user_id = users.id
    LEFT JOIN
      ( -- 同一ATユーザーごとに、銀行に連番(bank_number)を振ったテーブル
        SELECT
          at_user_bank_accounts.at_user_id,
          at_user_bank_accounts.fnc_nm,
          ( -- サブクエリで銀行に連番を振る
            SELECT
              COUNT(*)+1
            FROM
              at_user_bank_accounts AS t
            WHERE -- at_user_bank_accounts 内で at_user が同一で、id が違うものをカウント ＝ at_user ごとに連番が振られる 
              t.id < at_user_bank_accounts.id
              AND t.at_user_id = at_user_bank_accounts.at_user_id
          ) AS bank_number
        FROM
          at_user_bank_accounts
      ) AS at_user_numbered_bank
    ON
       at_user_numbered_bank.at_user_id = at_users.id
    GROUP BY
      users.id
  ) AS at_user_numbered_bank
ON
  at_user_numbered_bank.user_id = u.id

LEFT JOIN -- 連携クレカ名
  (
    SELECT
      users.id as user_id,
      -- at_users.id で GROUP BY し、集約関数で銀行名を連結する
      -- 集約値に、 card_number ごとに変化する値を指定することで
      -- 特定の card_number のデータのみが残る 
      GROUP_CONCAT(CASE WHEN at_user_numbered_card.card_number = 1 THEN at_user_numbered_card.fnc_nm ELSE NULL END) AS クレカ１,
      GROUP_CONCAT(CASE WHEN at_user_numbered_card.card_number = 2 THEN at_user_numbered_card.fnc_nm ELSE NULL END) AS クレカ２,
      GROUP_CONCAT(CASE WHEN at_user_numbered_card.card_number = 3 THEN at_user_numbered_card.fnc_nm ELSE NULL END) AS クレカ３,
      GROUP_CONCAT(CASE WHEN at_user_numbered_card.card_number = 4 THEN at_user_numbered_card.fnc_nm ELSE NULL END) AS クレカ４,
      GROUP_CONCAT(CASE WHEN at_user_numbered_card.card_number = 5 THEN at_user_numbered_card.fnc_nm ELSE NULL END) AS クレカ５
    FROM
      users
    LEFT JOIN
      at_users
    ON
      at_users.user_id = users.id
    LEFT JOIN
      ( -- 同一ATユーザーごとに、銀行に連番(card_number)を振ったテーブル
        SELECT
          at_user_card_accounts.at_user_id,
          at_user_card_accounts.fnc_nm,
          ( -- サブクエリで銀行に連番を振る
            SELECT
              COUNT(*)+1
            FROM
              at_user_card_accounts AS t
            WHERE -- at_user_card_accounts 内で at_user が同一で、id が違うものをカウント ＝ at_user ごとに連番が振られる 
              t.id < at_user_card_accounts.id
              AND t.at_user_id = at_user_card_accounts.at_user_id
          ) AS card_number
        FROM
          at_user_card_accounts
      ) AS at_user_numbered_card
    ON
       at_user_numbered_card.at_user_id = at_users.id
    GROUP BY
      users.id
  ) AS at_user_numbered_card
ON
  at_user_numbered_card.user_id = u.id

LEFT JOIN -- 連携電子マネー名
  (
    SELECT
      users.id as user_id,
      -- at_users.id で GROUP BY し、集約関数で銀行名を連結する
      -- 集約値に、 emoney_number ごとに変化する値を指定することで
      -- 特定の emoney_number のデータのみが残る 
      GROUP_CONCAT(CASE WHEN at_user_numbered_emoney.emoney_number = 1 THEN at_user_numbered_emoney.fnc_nm ELSE NULL END) AS IC１,
      GROUP_CONCAT(CASE WHEN at_user_numbered_emoney.emoney_number = 2 THEN at_user_numbered_emoney.fnc_nm ELSE NULL END) AS IC２,
      GROUP_CONCAT(CASE WHEN at_user_numbered_emoney.emoney_number = 3 THEN at_user_numbered_emoney.fnc_nm ELSE NULL END) AS IC３,
      GROUP_CONCAT(CASE WHEN at_user_numbered_emoney.emoney_number = 4 THEN at_user_numbered_emoney.fnc_nm ELSE NULL END) AS IC４,
      GROUP_CONCAT(CASE WHEN at_user_numbered_emoney.emoney_number = 5 THEN at_user_numbered_emoney.fnc_nm ELSE NULL END) AS IC５
    FROM
      users
    LEFT JOIN
      at_users
    ON
      at_users.user_id = users.id
    LEFT JOIN
      ( -- 同一ATユーザーごとに、銀行に連番(emoney_number)を振ったテーブル
        SELECT
          at_user_emoney_service_accounts.at_user_id,
          at_user_emoney_service_accounts.fnc_nm,
          ( -- サブクエリで銀行に連番を振る
            SELECT
              COUNT(*)+1
            FROM
              at_user_emoney_service_accounts AS t
            WHERE -- at_user_emoney_service_accounts 内で at_user が同一で、id が違うものをカウント ＝ at_user ごとに連番が振られる 
              t.id < at_user_emoney_service_accounts.id
              AND t.at_user_id = at_user_emoney_service_accounts.at_user_id
          ) AS emoney_number
        FROM
          at_user_emoney_service_accounts
      ) AS at_user_numbered_emoney
    ON
       at_user_numbered_emoney.at_user_id = at_users.id
    GROUP BY
      users.id
  ) AS at_user_numbered_emoney
ON
  at_user_numbered_emoney.user_id = u.id

LEFT JOIN -- 診断タイプ(最大ステップ数の時のbudget_question_idで判別可能)
  (
    SELECT
      ubq.user_id, 
      ubq.budget_question_id,
      max_step_teble.max_step
    FROM
      users AS u
    LEFT JOIN
      user_budget_questions AS ubq
    ON
      ubq.user_id = u.id
    LEFT JOIN
      (
        SELECT
          ubq.user_id,
          max(ubq.step) AS max_step
        FROM
          users AS u
        LEFT JOIN
          user_budget_questions AS ubq
        ON
          ubq.user_id = u.id
        GROUP BY
          ubq.user_id
      ) AS max_step_teble
    ON
      max_step_teble.user_id = u.id
    WHERE
      max_step_teble.max_step = ubq.step
  ) AS max_step_teble
ON 
  max_step_teble.user_id = u.id

LEFT JOIN -- 金融機関を目標貯金に連携した時刻
  (
    SELECT
      users.id,
      max(CASE WHEN numbered_goal_settings_at_user_bank_account.bank_number = 1 THEN numbered_goal_settings_at_user_bank_account.created_at ELSE NULL END) AS 金融機関を目標貯金に連携した時刻１,
      max(CASE WHEN numbered_goal_settings_at_user_bank_account.bank_number = 2 THEN numbered_goal_settings_at_user_bank_account.created_at ELSE NULL END) AS 金融機関を目標貯金に連携した時刻２,
      max(CASE WHEN numbered_goal_settings_at_user_bank_account.bank_number = 3 THEN numbered_goal_settings_at_user_bank_account.created_at ELSE NULL END) AS 金融機関を目標貯金に連携した時刻３
    FROM
      users
  LEFT JOIN
    (
      SELECT
        *,
      (
        SELECT
        -- at_user_bank_account_id が NULLならカウントもNULLとする
          CASE
            WHEN goal_settings.at_user_bank_account_id IS NULL THEN NULL
            ELSE COUNT(*)+1
          END AS bank_number
        FROM
          (
             SELECT
               *
             FROM
               goal_settings
             WHERE
               at_user_bank_account_id IS NOT NULL -- at_user_bank_account_id が NULLを除いて連番を振る 
          ) as t 
        WHERE
          t.id < goal_settings.id -- 連番にするため、id同士で比較してカウントする
          AND t.user_id = goal_settings.user_id -- user_id でグルーピングされた連番とする
      ) AS bank_number
      FROM
        goal_settings
    ) AS numbered_goal_settings_at_user_bank_account
  ON
    numbered_goal_settings_at_user_bank_account.user_id = users.id
  GROUP BY
    users.id
  ) AS numbered_goal_settings_at_user_bank_account
ON 
  numbered_goal_settings_at_user_bank_account.id = u.id

LEFT JOIN -- 診断のQ1,Q2,Q3の回答用
  (
    SELECT
      tmp.user_id,
      step,
      budget_question_id,
      (
        SELECT 
          budget_question_id 
        FROM
          user_budget_questions
        WHERE
          user_budget_questions.user_id = tmp.user_id
          AND user_budget_questions.step = tmp.step - 1 -- 1つ前のbudget_question_id
      ) AS prev_question_id
    FROM
      user_budget_questions AS tmp
    WHERE
      budget_question_id IN (3,4) -- Q3に限定するため、budget_question_idの3,4とする
      AND NOT EXISTS 
      (
        SELECT
          1
        FROM
          user_budget_questions AS tmp2
        WHERE
          tmp.user_id = tmp2.user_id
          AND tmp.step < tmp2.step -- 前の選択肢に戻れる仕様を考慮
          AND tmp2.budget_question_id IN (3,4)
      )
  ) AS q3
ON
  q3.user_id = u.id

ORDER BY u.id