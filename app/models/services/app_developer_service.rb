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

    p res
    # p res['receipt']['in_app'].first

    fail StandardError, '007105' if res.blank?

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
    when 21002 # レシートのフォーマットのエラー
      p 'receipt NG'
      fail StandardError, '007101'
    when 21004 # 共有シークレットなど環境情報のエラー
      p 'secret NG'
      fail StandardError, '007102'
    when 21007 # 送信先は本番環境でもstagingの情報を返してきた場合のエラー
      fail StandardError, '007103'
    else
      fail StandardError, '007104'
    end

    # レシートの不一致
    unless res['latest_receipt'] != params['receipt_data']
      fail StandardError, '007106'
    end

    if res['receipt']['bundle_id'] != 'com.osidori.inc'
      fail StandardError, '007107'
    end


    res['latest_receipt_info'].each do |r|
      next unless r['transaction_id'].present? && r['purchase_date'].present? && r['expires_date'].present?

      # 期限切れを確認
      if r['expires_date'] < Time.zone.now
        # fail StandardError, '007108'
        next
      end

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
    fail StandardError, '007201' if res.blank?

    params = {
      'product_id' => params['product_id'],
      'purchase_token' => params['purchase_token'],
      'access_token' => res['access_token']
    }
    requester = AppDeveloperAPIRequest::GooglePlay::ReceiptVerification.new(params)
    res = AppDeveloperApiClient.new(requester).request

    p res # debug

    if res['orderId'].blank? || res['startTimeMillis'].blank? || res['expiryTimeMillis'].blank?
      fail StandardError, '007202'
    end
    # 購入情報と購入ログを更新
    save_google_play_purchase_and_purchase_log(res, params['product_id'])

    if @google_play_premium_plans[params['product_id']].blank?
      fail StandardError, '007203'
    end

    # 期限切れを確認
    if Time.zone.at(res['expiryTimeMillis'].to_i / 1000.0) < Time.zone.now
      #fail StandardError, '007204'
      return true
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
# params = {
#   'product_id' => 'monthly_plan',
#   'purchase_token' => 'aogipmpcmflncngblhbkfhje.AO-J1OwgR4DIW_tu7r9C9PYrAr1d5bjEQSqzpRQYvyLLuBMHVXxCu98bqkGGVGN-r_S_i86nQqxcj6ixfhpGqulQvaOWGQZRHfAr3kyOs3dWfXYgBiIt9K4'
# }
