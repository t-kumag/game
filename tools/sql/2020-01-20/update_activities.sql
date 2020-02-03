/* activity_type のurlを変更にする */
UPDATE activities SET activity_type = 'person_account_to_family_partner' WHERE activity_type = "person_account_to_familly_partner";
UPDATE activities SET activity_type = 'person_account_to_family' WHERE activity_type = "person_account_to_familly";
UPDATE activities SET activity_type = 'person_tran_to_family_partner' WHERE activity_type = "person_tran_to_familly_partner";
UPDATE activities SET activity_type = 'person_account_to_family' WHERE activity_type = "person_account_to_familly";

/* urlのfamillyをfamilyに変更する */
update activities set url = replace(url, 'familly', 'family') WHERE url LIKE "%familly%";
