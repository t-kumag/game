class Services::NoticeReadService

  def self.already_exists?(notice, notices_read, current_user)
    notices_read.find_by(notice_id: notice.id, user_id: current_user.id).present?
  end

  def self.fetch_notice_read(notice, current_user)
    {
        notice_id: notice.id,
        user_id: current_user.id,
        read: false
    }
  end

end