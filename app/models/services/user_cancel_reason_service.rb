class Services::UserCancelReasonService


  def initialize(user)
    @user = user
  end

  def register_cancel_reason(cancel_reason)
    Entities::UserCancelReason.new(
        user_id: @user.id,
        cancel_reason: cancel_reason,
    ).save!
  end

end
