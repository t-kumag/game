class Entities::UserGroup < ApplicationRecord
  belongs_to :group
  belongs_to :user
end
