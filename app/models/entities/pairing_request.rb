# == Schema Information
#
# Table name: pairing_requests
#
#  id           :bigint(8)        not null, primary key
#  from_user_id :bigint(8)
#  to_user_id   :bigint(8)
#  group_id     :bigint(8)
#  token        :string(255)
#  status       :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Entities::PairingRequest < ApplicationRecord
end
