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
  acts_as_paranoid
  has_one :at_user, dependent: :destroy

  has_one :user_icon
  has_many :access_grants, class_name: 'Doorkeeper::AccessGrant',
                           foreign_key: :resource_owner_id,
                           dependent: :delete_all # or :destroy if you need callbacks
  has_many :access_tokens, class_name: 'Doorkeeper::AccessToken',
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
                    length: { maximum: 256 }

  enum rank: { free: 0, premium: 1 }

  def reset_token
    self.token = generate_token
    self.token_expires_at = DateTime.now + 30
  end

  def change_password_reset_token
    self.token = generate_token
    self.token_expires_at = DateTime.now + 1.hour
  end

  def clear_token
    self.token = nil
    self.token_expires_at = nil
    save!
  end

  def self.token_authenticate!(token)
    params = {
      token: token
    }
    find_by(params)
  end

  def generate_token
    # TODO　envなどから参照する
    salt = 'sjdhp2wys5ga4a2ks'
    time = DateTime.now
    Digest::SHA256.hexdigest(id.to_s + time.to_s + salt)
  end

  delegate :group_id, to: :participate_group, allow_nil: true

  def self.temporary_user(email)
    find_by(email: email, email_authenticated: 0)
  end

  def partner_user
    return {} if group_id.blank?
    participate_group = Entities::ParticipateGroup.where.not(user_id: id).where(group_id: group_id).first
    return {} if participate_group.blank?
    Entities::User.find(participate_group.user_id)
  end
end
