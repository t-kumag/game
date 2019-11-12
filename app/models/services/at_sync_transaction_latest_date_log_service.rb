class Services::AtSyncTransactionLatestDateLogService

  def self.get_latest_one(financier_account_type_key, account)
    case financier_account_type_key
    when "at_user_card_account_id"
      Entities::AtSyncTransactionLatestDateLog.order(id: :desc).where(at_user_card_account_id: account.id).pluck("latest_date").first
    when "at_user_bank_account_id"
      Entities::AtSyncTransactionLatestDateLog.order(id: :desc).where(at_user_bank_account_id: account.id).pluck("latest_date").first
    when "at_user_emoney_service_account_id"
      Entities::AtSyncTransactionLatestDateLog.order(id: :desc).where(at_user_emoney_service_account_id: account.id).pluck("latest_date").first
    end
  end


  def self.activity_sync_log(financier_account_type_key, account)
    activity_sync_log = []
    case financier_account_type_key
    when "at_user_card_account_id"
     activity_sync_log = set_at_user_card_account_id(account)
    when "at_user_bank_account_id"
     activity_sync_log = set_at_user_bank_account_id(account)
    when "at_user_emoney_service_account_id"
      activity_sync_log = set_at_user_emoney_service_account_id(account)
    end
    activity_sync_log.save!
  end

  def self.set_at_user_card_account_id(account)
    Entities::AtSyncTransactionLatestDateLog.new(
        at_user_card_account_id: account.id,
        user_id: account.at_user.user_id,
        latest_date: DateTime.now
    )
  end

  def self.set_at_user_bank_account_id(account)
    Entities::AtSyncTransactionLatestDateLog.new(
        at_user_bank_account_id: account.id,
        user_id: account.at_user.user_id,
        latest_date: DateTime.now
    )
  end

  def self.set_at_user_emoney_service_account_id(account)
    Entities::AtSyncTransactionLatestDateLog.new(
        at_user_emoney_service_account_id: account.id,
        user_id: account.at_user.user_id,
        latest_date: DateTime.now
    )
  end
end
