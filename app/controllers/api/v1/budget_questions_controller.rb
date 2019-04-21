class Api::V1::BudgetQuestionsController < ApplicationController
  before_action :authenticate

  # POST /api/v1/budget-questions
  # {
  #    "budget_questions":[
  #       {
  #          "budget_question_id":1,
  #          "step":1
  #       },
  #       {
  #          "budget_question_id":2,
  #          "step":2
  #       }
  #    ]
  # }
  def create
    # TODO: バリデーション
    # TODO 例外処理と共通化
    begin
      if params[:budget_questions].present?
        UserBudgetQuestion.new.transaction do
          params[:budget_questions].each do |budget_question|
            UserBudgetQuestion.new(
              user_id: @current_user.id,
              budget_question_id: budget_question[:budget_question_id],
              step: budget_question[:step]
            ).save
          end
        end
      end
    rescue ActiveRecord::RecordInvalid => db_err
      p db_err
      render(json: {}, status: 400) && return
    rescue => exception
      p exception
      render(json: {}, status: 400) && return
    end
    render json: {}, status: 200
  end
end
