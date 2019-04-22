# == Schema Information
#
# Table name: participate_groups
#
#  id         :bigint(8)        not null, primary key
#  group_id   :bigint(8)
#  user_id    :bigint(8)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Entities::ParticipateGroup < ApplicationRecord
  # TODO participate_groupsがinsertされないのでコメント
  #belongs_to :users
  belongs_to :group
end
