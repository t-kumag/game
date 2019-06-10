# == Schema Information
#
# Table name: at_users
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  at_user_id :string(255)
#

require "securerandom"

class Entities::AtUser < ApplicationRecord
  belongs_to :user
  has_many :at_user_bank_accounts
  has_many :at_user_card_accounts
  has_many :at_user_emoney_service_accounts
  has_many :at_user_tokens, inverse_of: :at_user
  
  # envに移す
  ACCOUNT_NAME_PREFIX = "osdrdev"

  def self.create_at_user(user)
    begin
      at_user = self.new(
        {user_id: user.id}
      )
      at_user.password = at_user.generate_at_user_password
      at_user.save!
      params = {
        at_user_id: at_user.at_user_id,
        at_user_password: at_user.password,
        at_user_email: at_user.at_user_email,
      }
      requester = AtAPIRequest::AtUser::CreateUser.new(params)
      res = AtAPIClient.new(requester).request
      return at_user
    rescue AtAPIStandardError => api_err
      raise api_err
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
    end
  end

  def at_user_email
    return "#{ACCOUNT_NAME_PREFIX}-#{self.id}@osdr.dev.co"
  end

  # def at_user_id
  #   return "#{ACCOUNT_NAME_PREFIX}_#{self.id}"
  # end

  private

  def generate_at_user_password
    return Digest::MD5.hexdigest("#{Time.new.to_i.to_s}#{SecureRandom.hex}")
  end
end
