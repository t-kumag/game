-- at_user_bank_account_idのbalanceをinsert
INSERT INTO balance_logs(
     at_user_bank_account_id
    ,amount
    ,date
    ,created_at
    ,updated_at
)
SELECT id
      ,balance
      ,'2019-09-30 23:59:59'
      ,NOW()
      ,NOW()

FROM   at_user_bank_accounts as ab
WHERE  ab.deleted_at is null;

-- at_user_emoney_service_account_idのbalanceをinsert
INSERT INTO balance_logs(
     at_user_emoney_service_account_id
    ,amount
    ,date
    ,created_at
    ,updated_at
)
SELECT id
      ,balance
      ,'2019-09-30 23:59:59'
      ,NOW()
      ,NOW()

FROM   at_user_emoney_service_accounts as ae
WHERE  ae.deleted_at is null;

-- 実行確認
select * from at_user_bank_accounts left join balance_logs
on at_user_bank_accounts.id = balance_logs.at_user_bank_account_id
where at_user_bank_accounts.deleted_at is null;

select * from at_user_emoney_service_accounts left join balance_logs
on at_user_emoney_service_accounts.id = balance_logs.at_user_emoney_service_account_id
where at_user_emoney_service_accounts.deleted_at is null;

-- 2019-09-30 19:00 475件