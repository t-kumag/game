# 既存データにメッセージを埋め込むためのSQL
UPDATE  dev_osdr_db.activities SET message = "銀行口座の支出があります" where activity_type = "individual_bank_outcome";
UPDATE  dev_osdr_db.activities SET message = "銀行口座に収入があります。" where activity_type = "individual_bank_income";
UPDATE  dev_osdr_db.activities SET message = "クレジットカードの支出があります。" where activity_type = "individual_card_outcome";
UPDATE  dev_osdr_db.activities SET message = "電子マネーの支出があります。" where activity_type = "individual_emoney_outcome";
UPDATE  dev_osdr_db.activities SET message = "電子マネーに収入があります。" where activity_type = "individual_emoney_income";
UPDATE  dev_osdr_db.activities SET message = "夫婦の銀行口座の支出があります。" where activity_type = "partner_bank_outcome";
UPDATE  dev_osdr_db.activities SET message = "夫婦の銀行口座に収入があります。" where activity_type = "partner_bank_income";
UPDATE  dev_osdr_db.activities SET message = "手動で明細が作成されました。" where activity_type = "individual_manual_outcome";
UPDATE  dev_osdr_db.activities SET message = "夫婦のクレジットカードの支出があります" where activity_type = "partner_card_outcome";
UPDATE  dev_osdr_db.activities SET message = "夫婦の電子マネーの支出があります。" where activity_type = "partner_emoney_outcome";
UPDATE  dev_osdr_db.activities SET message = "夫婦の電子マネーに収入があります。" where activity_type = "partner_emoney_income";
UPDATE  dev_osdr_db.activities SET message = "ペアリングが完了しました。" where activity_type = "pairing_created";
UPDATE  dev_osdr_db.activities SET message = "目標が作成されました" where activity_type = "goal_created";
UPDATE  dev_osdr_db.activities SET message = "目標に入金がありました。" where activity_type = "goal_add_money";
