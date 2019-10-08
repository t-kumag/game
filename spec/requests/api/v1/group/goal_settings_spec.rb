require 'rails_helper'

RSpec.describe Api::V1::Group::GoalSettingsController do
  let(:user) { create(:pairing_user_partner_at_user_bank_accounts) }
  let(:headers) { { Authorization: 'Bearer ' + user.partner_user.token } } 
  let(:params) { { 
    at_user_bank_account_id: user.partner_user.at_user.at_user_bank_accounts.first.id,
    monthly_amount: 100000,
    first_amount: 50000
  } }
  let!(:goal_type) { create(:goal_type, :all_goal_type) } 
  let(:goal) { create(:goal, :with_goal_settings, user_id: user.id, group_id: user.group_id) }

  describe '#create' do
    context 'success' do
      it 'response 200' do
        post "/api/v1/group/goals/#{goal.id}/goal-settings", params: params, as: :json, headers: headers
        expect(response.status).to eq 200
      end
    end
  end

end