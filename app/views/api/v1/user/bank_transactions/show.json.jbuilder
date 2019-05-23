json.errors []
json.app do
  json.amount @response[:amount]
  json.used_date @response[:used_date]
  json.used_location @response[:used_location]
  json.payment_name @response[:payment_name]
  json.is_shared @response[:is_shared]
  json.at_transaction_category_id @response[:at_transaction_category_id]
  json.category_name1 @response[:category_name1]
  json.category_name2 @response[:category_name2]

# ・メモ
# 　・表示項目
# 　　　・入力対象者　：　自分、パートナー
# 　　　・入力日　　　：　yyyy/mm/dd
# 　　　・自由項目　　：　1ブロック：30文字以内
# 　　　・入力方法　　：　「メモを追加しましょう」にタップしたら、キーボード表示
# 　・ブロック数
# 　　　・最大10ブロックまで
# ・写真はβ版では対応しない
# ・保存
# 　・保存をタップすることで、データが更新され、明細画面は閉じられる
end

