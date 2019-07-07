class Services::UserCancelAnswerService


  def initialize(user)
    @user = user
  end

  def register_cancel_checklist(cancel_checklists)
    cancel_checklists.each do |cancel_checklist|
      Entities::UserCancelAnswer.new(
          user_id: @user.id,
          user_cancel_question_id: cancel_checklist,
      ).save!
    end
  end

end
