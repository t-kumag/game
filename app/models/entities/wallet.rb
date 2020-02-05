class Entities::Wallet < ApplicationRecord
  acts_as_paranoid # 論理削除
  validates :user_id, presence: true
  belongs_to :user



end
