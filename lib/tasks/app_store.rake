# 課金ユーザーの自動更新の確認
# 有料から無料へ戻す処理
# ケース1. 自動更新に成功している アプリと同じ購入フローを通る
# latest_receipt_infoの中の最新レシートが持つtransactionIdがサーバ未登録の値である

# ケース2. まだ更新に成功していないが、今後成功する可能性がある　チェックしない
# pending_renewal_infoのある要素の項目is_in_billing_retry_periodが"1"である

# ケース3. その購読は自動更新されない 無料ユーザーに戻す
# 有効期限を過ぎている
# 以下のいずれかを満たす
# pending_renewal_infoの全要素の項目is_in_billing_retry_periodが"0"である
# 同リストの全要素の項目auto_renew_statusが"0"である

# 自動更新の対象
# 有料ユーザー かつ 有効期限が切れているユーザー

# CMD: rake app_store:update_purchase
namespace :app_store do
  desc "AppStore 課金の自動更新状況を更新する"
  task update_purchase: :environment do
    require 'parallel'
    parallel_num = 2 # スレッド数 指定数分のレコードを保持しスレッド処理する
    expire_day = Time.zone.now

    Entities::User.where(rank: 1).find_in_batches(batch_size: parallel_num) do |users|
      Parallel.each(users, in_processes: parallel_num) do |user|
        begin
          # 有効期限が残っているればskip
          purchases = Entities::UserPurchase.where(user_id: user.id).
                      where.not(app_store_premium_plan_id: nil).
                      where('subscription_expires_at > ?', expire_day)
          next if purchases.present?

          # 有効期限が残っていなければ自動更新の確認
          purchases = Entities::UserPurchase.where(user_id: user.id).
                      where.not(app_store_premium_plan_id: nil).
                      where('subscription_expires_at < ?', expire_day)
          purchases.each do |purchase|
            next if purchase.blank?
            # レシート取得
            purchase_log = Entities::UserAppStorePurchaseLog.find_by(transaction_id: purchase.order_transaction_id)
            next if purchase_log.blank?

            # 購入情報更新
            Services::AppDeveloperService.new(@current_user).app_store_receipt_verification('receipt_data' => purchase_log.receipt)

            # 購入状況問合せ
            requester = AppDeveloperAPIRequest::AppStore::ReceiptVerification.new('receipt_data' => purchase_log.receipt)
            res = AppDeveloperApiClient.new(requester).request
            next if res.blank? # TODO: レスポンスが無かった場合の処理

            # 下記の対象ユーザーを無料ユーザーに戻す
            # サブスクリプションの有効期限を過ぎている
            # ユーザーがauto_renew_statusの自動更新をオフにした
            # 有効期限が切れたがアップルが自動更新を試みているか。is_in_billing_retry_periodがオフになっている
            res['pending_renewal_info'].each do |info|
              if info['auto_renew_status'] === '0' && info['is_in_billing_retry_period'] === '0'
                user.update_rank_free # 無料ユーザーに戻す
              end
            end
          end
        rescue => e
          p e
        end
      end
    end
  end
end
