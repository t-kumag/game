# == Schema Information
#
# Table name: user_budget_questions
#
#  id                 :bigint(8)        not null, primary key
#  user_id            :bigint(8)
#  budget_question_id :bigint(8)
#  step               :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Entities::UserBudgetQuestion < ApplicationRecord
  belongs_to :user
end

