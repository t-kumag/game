json.meta do
  json.error @error if @error
end
json.activities do
  json.array!(@activities) do |n|
    json.day n.created_at.strftime('%Y-%m-%d')
    json.type ""
    json.url n.url
    json.message n.message
  end
end




#
#  day     : 日付を意味する
#  type    : 旧設計のため不要、今回は影響を考えて空の配列で返す。
#  url     : 遷移先URLの記入
#  message : それぞれのアクティビティタイプの文言を返す
#
#
# 例1)サンプル
# {
#   "activities": [
#     {
#       "day": "2019-08-09",
#       "type": "",
#       "url": "osidori://pairing-completed",
#       "message": "ペアリングが完了しました"
#     },
#     {
#       "day": "2019-08-08",
#       "type": "",
#       "url": "osidori://",
#       "message": "目標貯金「テスト目標」が作成されました"
#     },
#     {
#       "day": "2019-08-07",
#       "type": "",
#       "url": "osidori://",
#       "message": "目標貯金「テスト目標」に追加貯金しました"
#     }
#   ]
# }
#
#
#
