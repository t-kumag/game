class Services::AppDeveloperService
  def initialize(user)
    @user = user
    @app_store_premium_plans = Entities::AppStorePremiumPlan.all_plans
    @google_play_premium_plans = Entities::GooglePlayPremiumPlan.all_plans
  end

  # TODO: バッチからも参照する予定
  def app_store_receipt_verification(params)
    requester = AppDeveloperAPIRequest::AppStore::ReceiptVerification.new({'receipt_data' => params['receipt_data']})
    res = AppDeveloperApiClient.new(requester).request

    # p res['latest_receipt_info']
    # p res['receipt']['in_app'].first

    fail StandardError, 'Error App Store Receipt Verification Response Empty' if res.blank?

    # # TODO debug
    # res['status'] = 0
    # res = {'receipt' =>{'latest_receipt_info' => [{'product_id' => "#{Settings.app_store_bundle_id}.indivisualMonthlySubscription"}]}}
    # res['receipt']['bundle_id'] = "com.osidori.inc"
    # res['latest_receipt'] = nil
    # # TODO debug
    #

    case res['status']
    when 0
      p 'status OK'
    when 21002 # TODO: 送信したレシートのフォーマットのエラー
      p 'receipt NG'
      fail StandardError, 'Error App Store Receipt Verification 21002'
    when 21004 # TODO: 購入情報エラー　共有シークレットが間違っている
      p 'secret NG'
      fail StandardError, 'Error App Store Receipt Verification 21004'
    when 21007 # TODO: prod環境でもstagingの情報を返す場合がある
      p 'enviroment NG'
      fail StandardError, 'Error App Store Receipt Verification 21007'
    else
      fail StandardError, 'Error App Store Receipt Verification Status NG'
    end

    unless res['latest_receipt'] != params['receipt_data']
      fail StandardError, 'Error App Store Receipt Verification Receipt NG'
    end

    if res['receipt']['bundle_id'] != 'com.osidori.inc'
      fail StandardError, 'Error App Store Receipt Verification Bundle Id NG'
    end

    res['latest_receipt_info'].each do |r|
      #
      next unless r['transaction_id'].present? && r['purchase_date'].present? && r['expires_date'].present?
      # 購入情報と購入ログを更新
      save_app_store_purchase_and_purchase_log(r, res['latest_receipt'])

      # プランごとに課金状態を更新
      next if @app_store_premium_plans[r['product_id']].blank?
      case r['product_id']
      when "#{Settings.app_store_bundle_id}.indivisualMonthlySubscription"
        @user.update_rank_premium
      when "#{Settings.app_store_bundle_id}.indivisualYearlySubscription"
        @user.update_rank_premium
      when "#{Settings.app_store_bundle_id}.familyMonthlySubscription"
        @user.update_rank_premium
        @user.partner_user.update_rank_premium if @user.partner_user.present?
      when "#{Settings.app_store_bundle_id}.familyYearlySubscription"
        @user.update_rank_premium
        @user.partner_user.update_rank_premium if @user.partner_user.present?
      end
    end

    true
  rescue => e
    raise e
  end

  def save_app_store_purchase_and_purchase_log(row, receipt)
    purchase_log = Entities::UserAppStorePurchaseLog.find_by(transaction_id: row['transaction_id'])
    params = {
      transaction_id: row['transaction_id'],
      user_id: @user.id,
      purchase_date: row['purchase_date'],
      expires_date: row['expires_date'],
      product_id: row['product_id'],
      app_store_premium_plan_id: @app_store_premium_plans[row['product_id']].id,
      is_trial_period: row['is_trial_period'],
      receipt: receipt
    }
    if purchase_log.blank?
      Entities::UserAppStorePurchaseLog.create!(params)
    else
      purchase_log.update!(params)
    end

    purchase = Entities::UserPurchase.find_by(order_transaction_id: row['transaction_id'])
    params = {
      user_id: @user.id,
      app_store_premium_plan_id: @app_store_premium_plans[row['product_id']].id,
      order_transaction_id: row['transaction_id'],
      subscription_start_at: row['purchase_date'],
      subscription_expires_at: row['expires_date'],
      purchase_at: row['purchase_date']
    }
    if purchase.blank?
      Entities::UserPurchase.create!(params)
    else
      purchase.update!(params)
    end
  end

  def google_play_receipt_verification(params)
    requester = AppDeveloperAPIRequest::GooglePlay::GeAccessToken.new
    res = AppDeveloperApiClient.new(requester).request
    fail StandardError, 'Error Google Play Receipt Verification Response Empty' if res.blank?

    params = {
      'product_id' => params['product_id'],
      'purchase_token' => params['purchase_token'],
      'access_token' => res['access_token']
    }
    requester = AppDeveloperAPIRequest::GooglePlay::ReceiptVerification.new(params)
    res = AppDeveloperApiClient.new(requester).request

    p res # debug

    if res['orderId'].blank? || res['startTimeMillis'].blank? || res['expiryTimeMillis'].blank?
      fail StandardError, 'Error Google Play Receipt Verification Empty orderId,startTimeMillis,expiryTimeMillis'
    end
    # 購入情報と購入ログを更新
    save_google_play_purchase_and_purchase_log(res, params['product_id'])

    if @google_play_premium_plans[params['product_id']].blank?
      fail StandardError, 'Error Google Play Receipt Verification Not Found plan'
    end
    if Time.zone.at(res['expiryTimeMillis'].to_i / 1000.0) < Time.zone.now
      fail StandardError, 'Error Google Play Receipt Verification Over Expiry'
    end

    case params['product_id']
    when 'monthly_plan'
      @user.update_rank_premium
    when 'yearly_plan'
      @user.update_rank_premium
    when 'monthly_plan_with_partner'
      @user.update_rank_premium
      @user.partner_user.update_rank_premium if @user.partner_user.present?
    when 'yearly_plan_with_partner'
      @user.update_rank_premium
      @user.partner_user.update_rank_premium if @user.partner_user.present?
    end

    true
  rescue => e
    raise e
  end

  def save_google_play_purchase_and_purchase_log(row, product_id)
    purchase_log = Entities::UserGooglePlayPurchaseLog.find_by(order_id: row['orderId'])
    params = {
      google_play_premium_plan_id: @google_play_premium_plans[product_id].id,
      order_id: row['orderId'],
      user_id: @user.id,
      auto_renewing: row['autoRenewing'],
      start_time_millis: Time.zone.at(row['startTimeMillis'].to_i / 1000.0).strftime('%Y-%m-%d %H:%M:%S'),
      expiry_time_millis: Time.zone.at(row['expiryTimeMillis'].to_i / 1000.0).strftime('%Y-%m-%d %H:%M:%S'),
      purchase_token: row['purchaseToken']
    }

    if purchase_log.blank?
      Entities::UserGooglePlayPurchaseLog.create!(params)
    else
      purchase_log.update!(params)
    end

    purchase = Entities::UserPurchase.find_by(order_transaction_id: row['orderId'])
    params = {
      user_id: @user.id,
      google_play_premium_plan_id: @google_play_premium_plans[product_id].id,
      order_transaction_id: row['orderId'],
      subscription_start_at: Time.zone.at(row['startTimeMillis'].to_i / 1000.0).strftime('%Y-%m-%d %H:%M:%S'),
      subscription_expires_at: Time.zone.at(row['expiryTimeMillis'].to_i / 1000.0).strftime('%Y-%m-%d %H:%M:%S'),
      purchase_at: Time.zone.now
    }
    if purchase.blank?
      Entities::UserPurchase.create!(params)
    else
      purchase.update!(params)
    end
  end

  private
end

# params = {
#     "product_id" => "monthly_plan",
#     "purchase_token" => "aogipmpcmflncngblhbkfhje.AO-J1OwgR4DIW_tu7r9C9PYrAr1d5bjEQSqzpRQYvyLLuBMHVXxCu98bqkGGVGN-r_S_i86nQqxcj6ixfhpGqulQvaOWGQZRHfAr3kyOs3dWfXYgBiIt9K4",
#     "access_token" => "ya29.a0Ae4lvC3sHZoyoa1yQe_jRzT8N3IBppYq9g0bI9Z3aDKiqlka28jTAXg0eJR3UfQHmZwdGUEM8KQJ87vIhQiYs9j3iijzjaCnfcodp8BhTup45o8WSmaVuPaTFhiv4jJ2GOoRzlUg_Gxq8A8Purm4-9GVb2vKqy275R_6"
#     }
#
#
params = {
  'product_id' => 'monthly_plan',
  'purchase_token' => 'aogipmpcmflncngblhbkfhje.AO-J1OwgR4DIW_tu7r9C9PYrAr1d5bjEQSqzpRQYvyLLuBMHVXxCu98bqkGGVGN-r_S_i86nQqxcj6ixfhpGqulQvaOWGQZRHfAr3kyOs3dWfXYgBiIt9K4'
}
