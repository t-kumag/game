# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# TODO
Entities::User.create(email: 'test01@example.com', password_digest: 'test01', token: 'xxxxxxxxxxx01', token_expires_at: '2019-06-01 12:00:00')
Entities::User.create(email: 'test02@example.com', password_digest: 'test02', token: 'xxxxxxxxxxx02', token_expires_at: '2019-06-01 12:00:00')
Entities::User.create(email: 'test03@example.com', password_digest: 'test03', token: 'xxxxxxxxxxx03', token_expires_at: '2019-06-01 12:00:00')
Entities::User.create(email: 'test04@example.com', password_digest: 'test04', token: 'xxxxxxxxxxx04', token_expires_at: '2019-06-01 12:00:00')
Entities::User.create(email: 'test88@example.com', password_digest: 'test88', token: 'qxxxxxxxxxx88', token_expires_at: '2019-06-01 12:00:00')

# at_transaction_categories
Entities::AtTransactionCategory.create(id:1,at_category_id: '0000', category_name1: '未分類', category_name2: '未分類', at_grouped_categories_id: 1)
Entities::AtTransactionCategory.create(id:2,at_category_id: '0181', category_name1: '食費', category_name2: '昼食', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:3,at_category_id: '0182', category_name1: '食費', category_name2: '外食', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:4,at_category_id: '0101', category_name1: '食費', category_name2: '和食', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:5,at_category_id: '0102', category_name1: '食費', category_name2: '洋食', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:6,at_category_id: '0103', category_name1: '食費', category_name2: 'バイキング', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:7,at_category_id: '0104', category_name1: '食費', category_name2: '中華', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:8,at_category_id: '0105', category_name1: '食費', category_name2: 'アジア料理、エスニック', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:9,at_category_id: '0106', category_name1: '食費', category_name2: 'ラーメン', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:10,at_category_id: '0107', category_name1: '食費', category_name2: 'カレー', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:11,at_category_id: '0108', category_name1: '食費', category_name2: '焼肉、ホルモン、ジンギスカン', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:12,at_category_id: '0109', category_name1: '食費', category_name2: '鍋', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:13,at_category_id: '0111', category_name1: '食費', category_name2: '定食、食堂', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:14,at_category_id: '0112', category_name1: '食費', category_name2: '創作料理、無国籍料理', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:15,at_category_id: '0113', category_name1: '食費', category_name2: '自然食、薬膳、オーガニック', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:16,at_category_id: '0114', category_name1: '食費', category_name2: '持ち帰り、宅配', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:17,at_category_id: '0115', category_name1: '食費', category_name2: 'カフェ、喫茶店', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:18,at_category_id: '0116', category_name1: '食費', category_name2: 'コーヒー、茶葉専門店', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:19,at_category_id: '0117', category_name1: '食費', category_name2: 'パン、サンドイッチ', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:20,at_category_id: '0118', category_name1: '食費', category_name2: 'スイーツ', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:21,at_category_id: '0121', category_name1: '食費', category_name2: 'ディスコ、クラブハウス', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:22,at_category_id: '0123', category_name1: '食費', category_name2: 'ファミレス、ファストフード', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:23,at_category_id: '0124', category_name1: '食費', category_name2: 'パーティー、カラオケ', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:24,at_category_id: '0125', category_name1: '食費', category_name2: '屋形船、クルージング', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:25,at_category_id: '0126', category_name1: '食費', category_name2: 'テーマパークレストラン', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:26,at_category_id: '0127', category_name1: '食費', category_name2: 'オーベルジュ', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:27,at_category_id: '0128', category_name1: '食費', category_name2: 'その他', at_grouped_categories_id: 2)
Entities::AtTransactionCategory.create(id:28,at_category_id: '0205', category_name1: '日用品', category_name2: 'コンビニ、スーパー', at_grouped_categories_id: 4)
Entities::AtTransactionCategory.create(id:29,at_category_id: '0203', category_name1: '日用品', category_name2: '家電、携帯電話', at_grouped_categories_id: 4)
Entities::AtTransactionCategory.create(id:30,at_category_id: '0209', category_name1: '日用品', category_name2: 'ファッション、アクセサリー、時計', at_grouped_categories_id: 4)
Entities::AtTransactionCategory.create(id:31,at_category_id: '0208', category_name1: '日用品', category_name2: '趣味、スポーツ、工芸', at_grouped_categories_id: 4)
Entities::AtTransactionCategory.create(id:32,at_category_id: '0202', category_name1: '日用品', category_name2: 'ドラッグストア、市販薬', at_grouped_categories_id: 4)
Entities::AtTransactionCategory.create(id:33,at_category_id: '0210', category_name1: '日用品', category_name2: '食品、食材', at_grouped_categories_id: 4)
Entities::AtTransactionCategory.create(id:34,at_category_id: '0211', category_name1: '日用品', category_name2: '通信販売', at_grouped_categories_id: 4)
Entities::AtTransactionCategory.create(id:35,at_category_id: '0201', category_name1: '日用品', category_name2: 'メガネ、コンタクトレンズ', at_grouped_categories_id: 4)
Entities::AtTransactionCategory.create(id:36,at_category_id: '0204', category_name1: '日用品', category_name2: '百貨店、ショッピングセンター', at_grouped_categories_id: 4)
Entities::AtTransactionCategory.create(id:37,at_category_id: '0206', category_name1: '日用品', category_name2: 'リサイクル、ディスカウントショップ', at_grouped_categories_id: 4)
Entities::AtTransactionCategory.create(id:38,at_category_id: '0207', category_name1: '日用品', category_name2: '生活用品、インテリア', at_grouped_categories_id: 4)
Entities::AtTransactionCategory.create(id:39,at_category_id: '0381', category_name1: '交通', category_name2: '電車', at_grouped_categories_id: 7)
Entities::AtTransactionCategory.create(id:40,at_category_id: '0382', category_name1: '交通', category_name2: 'バス', at_grouped_categories_id: 7)
Entities::AtTransactionCategory.create(id:41,at_category_id: '0383', category_name1: '交通', category_name2: 'タクシー', at_grouped_categories_id: 7)
Entities::AtTransactionCategory.create(id:42,at_category_id: '0384', category_name1: '交通', category_name2: '飛行機', at_grouped_categories_id: 7)
Entities::AtTransactionCategory.create(id:43,at_category_id: '0306', category_name1: '交通', category_name2: '交通、レンタカー', at_grouped_categories_id: 7)
Entities::AtTransactionCategory.create(id:44,at_category_id: '0386', category_name1: '交通', category_name2: '船', at_grouped_categories_id: 7)
Entities::AtTransactionCategory.create(id:45,at_category_id: '0399', category_name1: '交通', category_name2: 'その他交通', at_grouped_categories_id: 7)
Entities::AtTransactionCategory.create(id:46,at_category_id: '0409', category_name1: '住宅・オフィス', category_name2: '住宅、不動産', at_grouped_categories_id: 9)
Entities::AtTransactionCategory.create(id:47,at_category_id: '0482', category_name1: '住宅・オフィス', category_name2: 'オフィス用品', at_grouped_categories_id: 9)
Entities::AtTransactionCategory.create(id:48,at_category_id: '0483', category_name1: '住宅・オフィス', category_name2: '地震・火災保険', at_grouped_categories_id: 9)
Entities::AtTransactionCategory.create(id:49,at_category_id: '0484', category_name1: '住宅・オフィス', category_name2: '設備', at_grouped_categories_id: 9)
Entities::AtTransactionCategory.create(id:50,at_category_id: '0410', category_name1: '住宅・オフィス', category_name2: '住宅設備', at_grouped_categories_id: 9)
Entities::AtTransactionCategory.create(id:51,at_category_id: '0581', category_name1: '水道光熱', category_name2: '電気', at_grouped_categories_id: 13)
Entities::AtTransactionCategory.create(id:52,at_category_id: '0582', category_name1: '水道光熱', category_name2: '水道', at_grouped_categories_id: 13)
Entities::AtTransactionCategory.create(id:53,at_category_id: '0583', category_name1: '水道光熱', category_name2: 'ガス', at_grouped_categories_id: 13)
Entities::AtTransactionCategory.create(id:54,at_category_id: '0599', category_name1: '水道光熱', category_name2: 'その他水道光熱費', at_grouped_categories_id: 13)
Entities::AtTransactionCategory.create(id:55,at_category_id: '0681', category_name1: '通信費・送料', category_name2: '携帯電話', at_grouped_categories_id: 13)
Entities::AtTransactionCategory.create(id:56,at_category_id: '0682', category_name1: '通信費・送料', category_name2: '固定電話', at_grouped_categories_id: 13)
Entities::AtTransactionCategory.create(id:57,at_category_id: '0412', category_name1: '通信費・送料', category_name2: '生活サービス', at_grouped_categories_id: 13)
Entities::AtTransactionCategory.create(id:58,at_category_id: '0684', category_name1: '通信費・送料', category_name2: 'インターネット', at_grouped_categories_id: 13)
Entities::AtTransactionCategory.create(id:59,at_category_id: '0685', category_name1: '通信費・送料', category_name2: '放送視聴料', at_grouped_categories_id: 13)
Entities::AtTransactionCategory.create(id:60,at_category_id: '0411', category_name1: '通信費・送料', category_name2: '郵便局、宅配便', at_grouped_categories_id: 13)
Entities::AtTransactionCategory.create(id:61,at_category_id: '0699', category_name1: '通信費・送料', category_name2: 'その他通信費・送料', at_grouped_categories_id: 13)
Entities::AtTransactionCategory.create(id:62,at_category_id: '0110', category_name1: '交際', category_name2: '居酒屋、ビアホール', at_grouped_categories_id: 3)
Entities::AtTransactionCategory.create(id:63,at_category_id: '0119', category_name1: '交際', category_name2: 'バー', at_grouped_categories_id: 3)
Entities::AtTransactionCategory.create(id:64,at_category_id: '0120', category_name1: '交際', category_name2: 'パブ、スナック', at_grouped_categories_id: 3)
Entities::AtTransactionCategory.create(id:65,at_category_id: '0122', category_name1: '交際', category_name2: 'ビアガーデン', at_grouped_categories_id: 3)
Entities::AtTransactionCategory.create(id:66,at_category_id: '0415', category_name1: '交際', category_name2: '葬祭、仏壇', at_grouped_categories_id: 3)
Entities::AtTransactionCategory.create(id:67,at_category_id: '0414', category_name1: '交際', category_name2: '結婚式場、結婚相談所', at_grouped_categories_id: 3)
Entities::AtTransactionCategory.create(id:68,at_category_id: '0783', category_name1: '交際', category_name2: 'プレゼント代', at_grouped_categories_id: 3)
Entities::AtTransactionCategory.create(id:69,at_category_id: '0784', category_name1: '交際', category_name2: 'お土産代', at_grouped_categories_id: 3)
Entities::AtTransactionCategory.create(id:70,at_category_id: '0799', category_name1: '交際', category_name2: 'その他交際', at_grouped_categories_id: 3)
Entities::AtTransactionCategory.create(id:71,at_category_id: '0401', category_name1: '医療', category_name2: '病院、診療所', at_grouped_categories_id: 5)
Entities::AtTransactionCategory.create(id:72,at_category_id: '0402', category_name1: '医療', category_name2: '薬局', at_grouped_categories_id: 5)
Entities::AtTransactionCategory.create(id:73,at_category_id: '0301', category_name1: '医療', category_name2: 'スポーツ', at_grouped_categories_id: 5)
Entities::AtTransactionCategory.create(id:74,at_category_id: '0403', category_name1: '医療', category_name2: 'マッサージ、整体、治療院', at_grouped_categories_id: 5)
Entities::AtTransactionCategory.create(id:75,at_category_id: '0404', category_name1: '医療', category_name2: '介護、福祉', at_grouped_categories_id: 5)
Entities::AtTransactionCategory.create(id:76,at_category_id: '0406', category_name1: '教育', category_name2: '学校、大学、専門学校', at_grouped_categories_id: 8)
Entities::AtTransactionCategory.create(id:77,at_category_id: '0407', category_name1: '教育', category_name2: '進学塾、予備校、各種学校', at_grouped_categories_id: 8)
Entities::AtTransactionCategory.create(id:78,at_category_id: '0408', category_name1: '教育', category_name2: '保育園、幼稚園、育児', at_grouped_categories_id: 8)
Entities::AtTransactionCategory.create(id:79,at_category_id: '0902', category_name1: '教育', category_name2: '教科書等', at_grouped_categories_id: 8)
Entities::AtTransactionCategory.create(id:80,at_category_id: '0903', category_name1: '教育', category_name2: '書籍', at_grouped_categories_id: 8)
Entities::AtTransactionCategory.create(id:81,at_category_id: '0904', category_name1: '教育', category_name2: '新聞・雑誌', at_grouped_categories_id: 8)
Entities::AtTransactionCategory.create(id:82,at_category_id: '0405', category_name1: '教育', category_name2: '趣味、習い事', at_grouped_categories_id: 8)
Entities::AtTransactionCategory.create(id:83,at_category_id: '0906', category_name1: '教育', category_name2: 'セミナー代', at_grouped_categories_id: 8)
Entities::AtTransactionCategory.create(id:84,at_category_id: '0999', category_name1: '教育', category_name2: 'その他教育', at_grouped_categories_id: 8)
Entities::AtTransactionCategory.create(id:85,at_category_id: '0416', category_name1: '年金・保険料', category_name2: '銀行、保険、金融', at_grouped_categories_id: 12)
Entities::AtTransactionCategory.create(id:86,at_category_id: '1002', category_name1: '年金・保険料', category_name2: '生命保険', at_grouped_categories_id: 12)
Entities::AtTransactionCategory.create(id:87,at_category_id: '1003', category_name1: '年金・保険料', category_name2: '医療保険', at_grouped_categories_id: 12)
Entities::AtTransactionCategory.create(id:88,at_category_id: '1084', category_name1: '年金・保険料', category_name2: '損害保険', at_grouped_categories_id: 12)
Entities::AtTransactionCategory.create(id:89,at_category_id: '1004', category_name1: '年金・保険料', category_name2: '年金', at_grouped_categories_id: 12)
Entities::AtTransactionCategory.create(id:90,at_category_id: '1099', category_name1: '年金・保険料', category_name2: 'その他年金・保険', at_grouped_categories_id: 12)
Entities::AtTransactionCategory.create(id:91,at_category_id: '1101', category_name1: '税金', category_name2: '所得税・住民税', at_grouped_categories_id: 14)
Entities::AtTransactionCategory.create(id:92,at_category_id: '1182', category_name1: '税金', category_name2: '消費税', at_grouped_categories_id: 14)
Entities::AtTransactionCategory.create(id:93,at_category_id: '1102', category_name1: '税金', category_name2: '収入印紙代', at_grouped_categories_id: 14)
Entities::AtTransactionCategory.create(id:94,at_category_id: '1199', category_name1: '税金', category_name2: 'その他税金', at_grouped_categories_id: 14)
Entities::AtTransactionCategory.create(id:95,at_category_id: '0413', category_name1: '車', category_name2: '自動車、バイク', at_grouped_categories_id: 11)
Entities::AtTransactionCategory.create(id:96,at_category_id: '1282', category_name1: '車', category_name2: '駐車場', at_grouped_categories_id: 11)
Entities::AtTransactionCategory.create(id:97,at_category_id: '1283', category_name1: '車', category_name2: '自動車保険', at_grouped_categories_id: 11)
Entities::AtTransactionCategory.create(id:98,at_category_id: '1284', category_name1: '車', category_name2: '道路料金', at_grouped_categories_id: 11)
Entities::AtTransactionCategory.create(id:99,at_category_id: '1285', category_name1: '車', category_name2: '自動⾞税', at_grouped_categories_id: 11)
Entities::AtTransactionCategory.create(id:100,at_category_id: '1286', category_name1: '車', category_name2: '維持費', at_grouped_categories_id: 11)
Entities::AtTransactionCategory.create(id:101,at_category_id: '1287', category_name1: '車', category_name2: '車検・整備', at_grouped_categories_id: 11)
Entities::AtTransactionCategory.create(id:102,at_category_id: '1288', category_name1: '車', category_name2: '自動車ローン', at_grouped_categories_id: 11)
Entities::AtTransactionCategory.create(id:103,at_category_id: '1289', category_name1: '車', category_name2: '車両', at_grouped_categories_id: 11)
Entities::AtTransactionCategory.create(id:104,at_category_id: '1299', category_name1: '車', category_name2: 'その他車', at_grouped_categories_id: 11)
Entities::AtTransactionCategory.create(id:105,at_category_id: '0304', category_name1: '趣味・娯楽', category_name2: 'ホテル、旅館', at_grouped_categories_id: 6)
Entities::AtTransactionCategory.create(id:106,at_category_id: '0307', category_name1: '趣味・娯楽', category_name2: '旅行サービス', at_grouped_categories_id: 6)
Entities::AtTransactionCategory.create(id:107,at_category_id: '0302', category_name1: '趣味・娯楽', category_name2: '麻雀、ゲームセンター', at_grouped_categories_id: 6)
Entities::AtTransactionCategory.create(id:108,at_category_id: '0303', category_name1: '趣味・娯楽', category_name2: 'レジャー、趣味', at_grouped_categories_id: 6)
Entities::AtTransactionCategory.create(id:109,at_category_id: '0305', category_name1: '趣味・娯楽', category_name2: 'エンタメ、映画館、美術館', at_grouped_categories_id: 6)
Entities::AtTransactionCategory.create(id:110,at_category_id: '0308', category_name1: '趣味・娯楽', category_name2: 'パチンコ、パチスロ', at_grouped_categories_id: 6)
Entities::AtTransactionCategory.create(id:111,at_category_id: '0418', category_name1: '趣味・娯楽', category_name2: '銭湯、浴場', at_grouped_categories_id: 6)
Entities::AtTransactionCategory.create(id:112,at_category_id: '0419', category_name1: '趣味・娯楽', category_name2: '美容、サロン', at_grouped_categories_id: 6)
Entities::AtTransactionCategory.create(id:113,at_category_id: '0417', category_name1: '趣味・娯楽', category_name2: 'ペット、動物病院', at_grouped_categories_id: 6)
Entities::AtTransactionCategory.create(id:114,at_category_id: '0423', category_name1: '趣味・娯楽', category_name2: '公共サービス、各種団体', at_grouped_categories_id: 6)
Entities::AtTransactionCategory.create(id:115,at_category_id: '0424', category_name1: '趣味・娯楽', category_name2: '寺院、神社', at_grouped_categories_id: 6)
Entities::AtTransactionCategory.create(id:116,at_category_id: '1481', category_name1: '投資', category_name2: '配当金', at_grouped_categories_id: 15)
Entities::AtTransactionCategory.create(id:117,at_category_id: '1482', category_name1: '投資', category_name2: '株の売却', at_grouped_categories_id: 15)
Entities::AtTransactionCategory.create(id:118,at_category_id: '1483', category_name1: '投資', category_name2: '株の購入', at_grouped_categories_id: 15)
Entities::AtTransactionCategory.create(id:119,at_category_id: '1499', category_name1: '投資', category_name2: 'その他投資', at_grouped_categories_id: 15)
Entities::AtTransactionCategory.create(id:120,at_category_id: '1581', category_name1: '返済', category_name2: 'カード返済', at_grouped_categories_id: 16)
Entities::AtTransactionCategory.create(id:121,at_category_id: '1582', category_name1: '返済', category_name2: 'ローン返済', at_grouped_categories_id: 16)
Entities::AtTransactionCategory.create(id:122,at_category_id: '1599', category_name1: '返済', category_name2: 'その他返済', at_grouped_categories_id: 16)
Entities::AtTransactionCategory.create(id:123,at_category_id: '1681', category_name1: '入金', category_name2: 'ATM入金', at_grouped_categories_id: 17)
Entities::AtTransactionCategory.create(id:124,at_category_id: '1682', category_name1: '入金', category_name2: '振込入金', at_grouped_categories_id: 17)
Entities::AtTransactionCategory.create(id:125,at_category_id: '1683', category_name1: '入金', category_name2: '清算入金', at_grouped_categories_id: 17)
Entities::AtTransactionCategory.create(id:126,at_category_id: '1684', category_name1: '入金', category_name2: '給与入金', at_grouped_categories_id: 17)
Entities::AtTransactionCategory.create(id:127,at_category_id: '1685', category_name1: '入金', category_name2: '賞与入金', at_grouped_categories_id: 17)
Entities::AtTransactionCategory.create(id:128,at_category_id: '1686', category_name1: '入金', category_name2: '貯金入金', at_grouped_categories_id: 17)
Entities::AtTransactionCategory.create(id:129,at_category_id: '1687', category_name1: '入金', category_name2: '配当等収入', at_grouped_categories_id: 17)
Entities::AtTransactionCategory.create(id:130,at_category_id: '1688', category_name1: '入金', category_name2: '雑収入', at_grouped_categories_id: 17)
Entities::AtTransactionCategory.create(id:131,at_category_id: '1689', category_name1: '入金', category_name2: '融資入金', at_grouped_categories_id: 17)
Entities::AtTransactionCategory.create(id:132,at_category_id: '1690', category_name1: '入金', category_name2: '家賃所得', at_grouped_categories_id: 17)
Entities::AtTransactionCategory.create(id:133,at_category_id: '1691', category_name1: '入金', category_name2: '利子所得', at_grouped_categories_id: 17)
Entities::AtTransactionCategory.create(id:134,at_category_id: '1692', category_name1: '入金', category_name2: '振込手数料入金', at_grouped_categories_id: 17)
Entities::AtTransactionCategory.create(id:135,at_category_id: '1699', category_name1: '入金', category_name2: 'その他入金', at_grouped_categories_id: 17)
Entities::AtTransactionCategory.create(id:136,at_category_id: '1781', category_name1: '出金', category_name2: 'ATM出金', at_grouped_categories_id: 18)
Entities::AtTransactionCategory.create(id:137,at_category_id: '1782', category_name1: '出金', category_name2: '雑支出', at_grouped_categories_id: 18)
Entities::AtTransactionCategory.create(id:138,at_category_id: '1783', category_name1: '出金', category_name2: '預金支出', at_grouped_categories_id: 18)
Entities::AtTransactionCategory.create(id:139,at_category_id: '1784', category_name1: '出金', category_name2: '寄付金', at_grouped_categories_id: 18)
Entities::AtTransactionCategory.create(id:140,at_category_id: '1785', category_name1: '出金', category_name2: '会費', at_grouped_categories_id: 18)
Entities::AtTransactionCategory.create(id:141,at_category_id: '1786', category_name1: '出金', category_name2: '定期預金', at_grouped_categories_id: 18)
Entities::AtTransactionCategory.create(id:142,at_category_id: '1787', category_name1: '出金', category_name2: '給与支払', at_grouped_categories_id: 18)
Entities::AtTransactionCategory.create(id:143,at_category_id: '1799', category_name1: '出金', category_name2: 'その他出金', at_grouped_categories_id: 18)
Entities::AtTransactionCategory.create(id:144,at_category_id: '1881', category_name1: '手数料', category_name2: '利息', at_grouped_categories_id: 19)
Entities::AtTransactionCategory.create(id:145,at_category_id: '1882', category_name1: '手数料', category_name2: '振込手数料', at_grouped_categories_id: 19)
Entities::AtTransactionCategory.create(id:146,at_category_id: '1883', category_name1: '手数料', category_name2: '振替手数料', at_grouped_categories_id: 19)
Entities::AtTransactionCategory.create(id:147,at_category_id: '1884', category_name1: '手数料', category_name2: '銀行手数料', at_grouped_categories_id: 19)
Entities::AtTransactionCategory.create(id:148,at_category_id: '1885', category_name1: '手数料', category_name2: 'ATM手数料', at_grouped_categories_id: 19)
Entities::AtTransactionCategory.create(id:149,at_category_id: '1899', category_name1: '手数料', category_name2: 'その他手数料', at_grouped_categories_id: 19)
Entities::AtTransactionCategory.create(id:150,at_category_id: '0420', category_name1: '未分類', category_name2: '専門職、弁護士、司法書士', at_grouped_categories_id: 1)
Entities::AtTransactionCategory.create(id:151,at_category_id: '0421', category_name1: '未分類', category_name2: '人材派遣', at_grouped_categories_id: 1)
Entities::AtTransactionCategory.create(id:152,at_category_id: '0422', category_name1: '未分類', category_name2: '官公庁', at_grouped_categories_id: 1)
Entities::AtTransactionCategory.create(id:153,at_category_id: '0425', category_name1: '未分類', category_name2: '避難所、避難場所', at_grouped_categories_id: 1)


# payment_method
Entities::PaymentMethod.create(name: '口座')
Entities::PaymentMethod.create(name: 'クレジットカード')

# BudgetQuestion
5.times do
  Entities::BudgetQuestion.create
end


# GoalType
Entities::GoalType.create(name: '住宅購入/頭金', img_url: 'test.png')
Entities::GoalType.create(name: '結婚/旅行', img_url: 'test.png')

# at_groupted_categories
Entities::AtGroupedCategory.create(id:1, category_name: '未分類');
Entities::AtGroupedCategory.create(id:2, category_name: '食費');
Entities::AtGroupedCategory.create(id:3, category_name: '交際');
Entities::AtGroupedCategory.create(id:4, category_name: '日用品');
Entities::AtGroupedCategory.create(id:5, category_name: '医療');
Entities::AtGroupedCategory.create(id:6, category_name: '趣味・娯楽');
Entities::AtGroupedCategory.create(id:7, category_name: '交通');
Entities::AtGroupedCategory.create(id:8, category_name: '教育');
Entities::AtGroupedCategory.create(id:9, category_name: '住宅・オフィス');
Entities::AtGroupedCategory.create(id:10, category_name: '通信費・送料');
Entities::AtGroupedCategory.create(id:11, category_name: '車');
Entities::AtGroupedCategory.create(id:12, category_name: '年金・保険料');
Entities::AtGroupedCategory.create(id:13, category_name: '水道光熱');
Entities::AtGroupedCategory.create(id:14, category_name: '税金');
Entities::AtGroupedCategory.create(id:15, category_name: '投資');
Entities::AtGroupedCategory.create(id:16, category_name: '返済');
Entities::AtGroupedCategory.create(id:17, category_name: '入金');
Entities::AtGroupedCategory.create(id:18, category_name: '出金');
Entities::AtGroupedCategory.create(id:19, category_name: '手数料');


# UserCancelQuestioin
Entities::UserCancelQuestion.create(id:1, cancel_reason: '金融機関の登録が難しかった');
Entities::UserCancelQuestion.create(id:2, cancel_reason: 'セキュリティの懸念があった');
Entities::UserCancelQuestion.create(id:3, cancel_reason: '他サービスの方が便利に感じた');
Entities::UserCancelQuestion.create(id:4, cancel_reason: '使いこなせなかった');
Entities::UserCancelQuestion.create(id:5, cancel_reason: 'あまり使わなかった');
Entities::UserCancelQuestion.create(id:6, cancel_reason: 'その他');
