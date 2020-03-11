class Entities::Wallet < ApplicationRecord
  RELATION_KEY = :wallet_id.freeze

  acts_as_paranoid # 論理削除
  validates :user_id, presence: true
  belongs_to :user
end
