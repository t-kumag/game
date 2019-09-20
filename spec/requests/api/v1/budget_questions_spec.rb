require 'rails_helper'

RSpec.describe 'budget_questions_controller' do
  let(:user) { create(:user) }
  let(:headers) { { Authorization: 'Bearer ' + user.token } }
  let(:params) { {
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
  } }
  let!(:budget_questions) { create_list(:budget_question, 10) }
  
  describe '#create' do
    context 'success' do
      it 'response 200' do
        post '/api/v1/budget-questions', params: params, headers: headers 
        expect(response.status).to eq 200
      end

      it 'increase three record of user_budget_questions' do
        post '/api/v1/budget-questions', params: params, headers: headers 
        expect(Entities::UserBudgetQuestion.where(user_id: user.id).count).to eq 3
      end
    end
  end
end