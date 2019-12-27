# typeをid 17はincome、それ以外はexpenceで更新する
UPDATE activities SET message = 'パートナーが金融機関を家族画面に登録しました' WHERE activity_type = "person_account_to_familly_partner";
UPDATE activities SET message = 'あなたが金融機関を家族画面に登録しました' WHERE activity_type = "person_account_to_familly";
