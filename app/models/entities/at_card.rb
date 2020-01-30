# == Schema Information
#
# Table name: at_cards
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  fnc_cd     :string(255)
#  fnc_nm     :string(255)
#

# TODO このモデルは使用しないので影響がなければ削除する 2020-01-30
# https://www.wrike.com/open.htm?id=452973113
class Entities::AtCard < ApplicationRecord
end
