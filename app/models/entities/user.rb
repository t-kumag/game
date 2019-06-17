# == Schema Information
#
# Table name: users
#
#  id                  :bigint(8)        not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  email               :string(255)
#  token               :string(255)
#  password_digest     :string(255)
#  email_authenticated :boolean          default(FALSE)
#  token_expires_at    :datetime
#

class Entities::User < ApplicationRecord

  has_one :at_user
  has_one :user_icon

  has_many :user_groups, dependent: :destroy
  has_many :groups, -> { distinct }, through: :user_groups
  has_many :access_grants, class_name: "Doorkeeper::AccessGrant",
          foreign_key: :resource_owner_id,
          dependent: :delete_all # or :destroy if you need callbacks
  has_many :access_tokens, class_name: "Doorkeeper::AccessToken",
          foreign_key: :resource_owner_id,
          dependent: :delete_all # or :destroy if you need callbacks
  has_one :participate_group
  has_one :group, through: :participate_group
  has_one :user_profile
  has_secure_password validations: true

  # email はメールアドレスとしての整合性と、仕様上の最大長をチェックする
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
                    uniqueness: true, 
                    format: { with: VALID_EMAIL_REGEX }, 
                    length: { maximum: 256}

  enum rank: { free: 0, premium: 1 }

  def reset_token
    self.token = generate_token
    self.token_expires_at = DateTime.now + 30
  end

  def clear_token
    self.token = nil
    self.token_expires_at = nil
    self.save!
  end

  def self.token_authenticate!(token)
    params = {
      token: token
    } 
    self.find_by(params)
  end

  def generate_token
    # TODO　envなどから参照する
    salt = "sjdhp2wys5ga4a2ks"
    time = DateTime.now
    return Digest::SHA256.hexdigest(self.id.to_s + time.to_s + salt)
  end

  def group_id
    self.participate_group.group_id
  end

end
