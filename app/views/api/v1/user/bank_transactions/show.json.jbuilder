json.meta do
  json.error  'sample'
end

json.app do
  json.amount @response.amount
  json.category @response.category
  json.used_date @response.use_date
  json.payment_type  @response.payment_type
  json.used_store @response.used_store
  json.group  @response.group
  
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

# {"tweet": {"text": "テキスト1", "title": "タイトル1"} }

