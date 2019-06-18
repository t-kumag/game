# == Schema Information
#
# Table name: groups
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Entities::Group < ApplicationRecord

  accepts_nested_attributes_for :user_groups
  has_many :goals
  has_many :participate_groups

end
