class Services::ActivitySyncDatesService

  def create_log(user_id, date)
    log = Entities::ActivitiesSyncDate.new(user_id: user_id, date: date)
    log.save!
  end

end
