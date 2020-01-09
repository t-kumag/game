class Services::NoticeMarkService

  def self.already_exists?(notice, notices_mark, current_user)
    notices_mark.find_by(notice_id: notice.id, user_id: current_user.id).present?
  end

  def self.fetch_notice_marks(notice, current_user)
    {
        notice_id: notice.id,
        user_id: current_user.id,
        mark: false
    }
  end

end