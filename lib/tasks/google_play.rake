# ケース1. 自動更新に成功している
# 戻り値の項目orderIdがサーバ未登録である
# expiryTimeMillisがリクエスト前の有効期限より将来の値である
#
#
# ケース2. まだ更新に成功していないが、今後成功する可能性がある
# 戻り値で示された有効期限expiryTimeMillisに達していない
# autoRenewingがtrueである
#
# ケース3. その購読は自動更新されない
# 戻り値で示された有効期限expiryTimeMillisが過去を示す

# 自動更新の対象
# 有料ユーザー かつ 有効期限が切れているユーザー

# CMD: rake google_play:update_purchase
namespace :google_play do
  desc "課金の自動更新を登録する"
  task update_purchase: :environment do
    require 'parallel'
    parallel_num = 2 # スレッド数 指定数分のレコードを保持しスレッド処理する
    expire_day = Time.zone.now

    Entities::User.where(rank: 1).find_in_batches(batch_size: parallel_num) do |users|
      Parallel.each(users, in_processes: parallel_num) do |user|
        begin
          # 有効期限が残っているればskip
          purchases = Entities::UserPurchase.where(user_id: user.id).
                      where.not(google_play_premium_plan_id: nil).
                      where('subscription_expires_at > ?', expire_day)
          next if purchases.present?

          # 有効期限が残っていなければ自動更新の確認
          purchases = Entities::UserPurchase.where(user_id: user.id).
                      where.not(google_play_premium_plan_id: nil).
                      where('subscription_expires_at < ?', expire_day)
          purchases.each do |purchase|
            next if purchase.blank?
            # レシート取得
            purchase_log = Entities::UserGooglePlayPurchaseLog.find_by(order_id: purchase.order_transaction_id)
            next if purchase_log.blank?
            params = {
              'product_id' => Entities::UserGooglePlayPurchaseLog.first.google_play_premium_plan.product_id,
              'purchase_token' => purchase_log.purchase_token
            }
            # 購入情報更新
            google_service = Services::AppDeveloperService.new(user)
            google_service.google_play_receipt_verification(params)
            params['access_token'] = google_service.google_play_access_token

            # 購入状況問合せ
            requester = AppDeveloperAPIRequest::GooglePlay::ReceiptVerification.new(params)
            res = AppDeveloperApiClient.new(requester).request
            p res
            next if res.blank? # TODO: レスポンスが無かった場合の処理

            # 下記の対象ユーザーを無料ユーザーに戻す
            if Time.zone.at(res['expiryTimeMillis'].to_i / 1000.0).strftime('%Y-%m-%d %H:%M:%S') < Time.zone.now
              user.update_rank_free # 無料ユーザーに戻す
            end
          end
        rescue => e
          p e
        end
      end
    end
  end
end
