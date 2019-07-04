class Services::AtSyncTransactionLatestDateLogService

  def self.get_latest_one(rec_key, account)
    Entities::AtSyncTransactionLatestDateLog.order(latest_date: :desc).where(rec_key: rec_key, user_id: account.at_user_id).pluck("latest_date").first
  end

  def activity_sync_log(rec_key, account)
    activity_sync_log = Entities::AtSyncTransactionLatestDateLog.new(rec_key:rec_key, user_id: account.at_user_id, latest_date: DateTime.now)
    activity_sync_log.save!
  end

end
