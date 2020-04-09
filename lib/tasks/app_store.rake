#TODO 有料から無料へ戻す処理
#TODO ケース1. 自動更新に成功している
#latest_receipt_infoの中の最新レシートが持つtransactionIdがサーバ未登録の値である

#TODO ケース2. まだ更新に成功していないが、今後成功する可能性がある
#pending_renewal_infoのある要素の項目is_in_billing_retry_periodが"1"である

#TODO ケース3. その購読は自動更新されない
# 有効期限を過ぎている
# 以下のいずれかを満たす
# pending_renewal_infoの全要素の項目is_in_billing_retry_periodが"0"である
# 同リストの全要素の項目auto_renew_statusが"0"である

# CMD: rake app_store:update_purchase
namespace :app_store do
  desc "課金の自動更新を登録する"
  task update_purchase: :environment do
    p "OK"
  end
end