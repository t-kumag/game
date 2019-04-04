class Api::V1::BudgetQuestionsController < ApplicationController
  before_action :authenticate

  def create
    # TODO バリデーション
    # TODO transaction
    if params[:budget_questions].present?
      Entities::UserBudgetQuestion.transaction do
        params[:budget_questions].each do |param|
          Entities::UserBudgetQuestion.create(
              user_id: @current_user.id,
              budget_question_id: param[:budget_question_id],
              step: param[:step]
          )
        end
      end
      # TODO 例外処理など
    end
    render json: {}, status: 200
  end

end
