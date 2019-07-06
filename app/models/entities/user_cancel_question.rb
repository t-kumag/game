class Entities::UserCancelQuestion < ApplicationRecord
  belongs_to :user_cancel_answer
  has_many :user_cancel_answer

end
