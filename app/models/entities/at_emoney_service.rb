# == Schema Information
#
# Table name: at_emoney_services
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  fnc_cd     :string(255)
#  fnc_nm     :string(255)
#

class Entities::AtEmoneyService < ApplicationRecord
end
