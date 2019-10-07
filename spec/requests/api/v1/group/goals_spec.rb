require 'rails_helper'

RSpec.describe Api::V1::Group::GoalsController do
  let(:user) { create(:pairing_user) }
  let(:headers) { { Authorization: 'Bearer ' + user.token } } 
  let(:params) { { 
    goals: {
      goal_type_id: 1,
      name: 'ラスベガス旅行資金',
      img_url: 'test.png',
      goal_amount: 1000000,
      start_date: '2019-01-01',
      end_date: '2019-12-31'
    },
    goal_settings: {
      at_user_bank_account_id: user.at_user.at_user_bank_accounts.first.id,
      monthly_amount: 100000,
      first_amount: 150000
    },
    partner_goal_settings: {
      monthly_amount: 100000,
      first_amount: 150000
    }
  } }
  let!(:goal_type) { create(:goal_type, :all_goal_type) } 

  describe '#create' do
    context 'success' do
      it 'response 200' do
        post '/api/v1/group/goals', params: params, as: :json, headers: headers
        expect(response.status).to eq 200
      end

      it 'increase one record of goal' do
        post '/api/v1/group/goals', params: params, as: :json, headers: headers
        expect(Entities::Goal.where(group_id: user.group_id).count).to eq 1
      end

      it 'increase two record of goal_setting' do
        post '/api/v1/group/goals', params: params, as: :json, headers: headers
        expect(Entities::GoalSetting.where(user_id: [user.id, user.partner_user.id]).count).to eq 2
      end

      it 'increase two record of activity' do
        post '/api/v1/group/goals', params: params, as: :json, headers: headers
        expect(Entities::Activity.where(group_id: user.group_id).count).to eq 2
      end
    end
  end

  describe '#update' do
    let(:params) { { 
      goals: {
        goal_type_id: 1,
        name: 'ハワイ旅行資金',
        img_url: 'test.png',
        goal_amount: 1000000,
        start_date: '2019-01-01',
        end_date: '2019-12-31'
      },
      goal_settings: {
        at_user_bank_account_id: user.at_user.at_user_bank_accounts.first.id,
        monthly_amount: 100000,
        first_amount: 150000,
        goal_setting_id: goal.goal_settings.find_by(user_id: user.id).id
      },
      partner_goal_settings: {
        monthly_amount: 100000,
        first_amount: 150000,
        goal_setting_id: goal.goal_settings.find_by(user_id: user.partner_user.id).id
      }
    } }

    let(:goal) { create(:goal, :with_goal_settings, user_id: user.id, group_id: user.group_id) }

    context 'success' do
      it 'response 200' do
        put "/api/v1/group/goals/#{goal.id}", params: params, as: :json, headers: headers
        expect(response.status).to eq 200
      end
    end
  end
end