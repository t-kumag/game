class Api::V1::BudgetQuestionsController < ApplicationController
  before_action :authenticate

  def create
    # TODO バリデーション
    # TODO transaction
    if params[:budget_questions].present?
      Entities::UserBudgetQuestion.transaction do
        params[:budget_questions].each do ||
          Entities::UserBudgetQuestion.create(
              user_id: @current_user.id,
              budget_question_id: params[:budget_question_id],
              step: params[:step]
          )
        end
      end
      # TODO 例外処理など

    end
    render json: {}, status: 200
  end

end
