# ケース1. 自動更新に成功している
# 戻り値の項目orderIdがサーバ未登録である
# expiryTimeMillisがリクエスト前の有効期限より将来の値である
#
#
# ケース2. まだ更新に成功していないが、今後成功する可能性がある
# 戻り値で示された有効期限expiryTimeMillisに達していない
# autoRenewingがtrueである

# CMD: rake google_play:update_purchase
namespace :google_play do
  desc "課金の自動更新を登録する"
  task update_purchase: :environment do
    p "OK"
  end
end