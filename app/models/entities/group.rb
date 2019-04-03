class Entities::Group < ApplicationRecord
  has_many :user_groups, dependent: :destroy
  has_many :users, through: :user_groups
  accepts_nested_attributes_for :user_groups
  has_many :goals
end
