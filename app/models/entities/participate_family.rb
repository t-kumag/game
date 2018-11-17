class Entities::ParticipateFamily < ApplicationRecord
  belongs_to :family
  belongs_to :user
end
