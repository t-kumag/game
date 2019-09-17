require 'rails_helper'

describe 'budget_questions_controller' do
  before(:each) do
    @user = create(:user)
    @headers = { "Authorization" => "Bearer " + @user.token}
  end

  it 'POST #create' do
    create_list(:budget_question, 10)
    
    params = {
      budget_questions: [
        {
          budget_question_id: 1,
          step: 1
        },
        {
          budget_question_id: 3,
          step: 2
        },
        {
          budget_question_id: 5,
          step: 3
        }
      ]
    }

    expect { 
      post "/api/v1/budget-questions", 
      params: params, 
      headers: @headers 
    }.to change(Entities::UserBudgetQuestion, :count).by(+3)

    expect(response.status).to eq 200
  end

end