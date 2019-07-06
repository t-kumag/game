class Services::UserCancelCommentService


  def initialize(user)
    @user = user
  end

  def register_cancel_comment(cancel_comment)
    Entities::UserCancelAnswer.new(
        user_id: @user.id,
        cancel_reason: cancel_comment,
    ).save!
  end

end
