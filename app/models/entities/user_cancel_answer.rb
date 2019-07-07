class Entities::UserCancelAnswer < ApplicationRecord
  has_one :user_cancel_question
end
