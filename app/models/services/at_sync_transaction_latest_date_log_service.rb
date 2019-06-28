class Services::AtSyncTransactionLatestDateLogService

  def get_activity_sync_latest_one(rec_key, account)
    Entities::AtSyncTransactionLatestDateLog.order(last_date: :desc).where(rec_key: rec_key, user_id: account.at_user_id).pluck("last_date").first
  end

  def activity_sync_log(rec_key, account)
    activity_sync_log = Entities::AtSyncTransactionLatestDateLog.new(rec_key:rec_key, user_id: account.at_user_id, last_date: DateTime.now)
    activity_sync_log.save!
  end

end
