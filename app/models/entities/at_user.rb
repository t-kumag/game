require "securerandom"

class Entities::AtUser < ApplicationRecord
  belongs_to :user
  has_many :at_user_bank_accounts
  has_many :at_user_card_accounts
  has_many :at_user_emoney_service_accounts

  # envに移す
  ACCOUNT_NAME_PREFIX = "osdrdev"

  def self.create_at_user(user)
    begin
      at_user = AtUser.new(
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
    rescue ActiveRecord::RecordInvalid => db_err
    rescue => exception
    end
  end

  def at_user_email
    return "#{ACCOUNT_NAME_PREFIX}-#{self.id}@osdr.dev.co"
  end

  def at_user_id
    return "#{ACCOUNT_NAME_PREFIX}_#{self.id}"
  end

  private

  def generate_at_user_password
    return Digest::MD5.hexdigest("#{Time.new.to_i.to_s}#{SecureRandom.hex}")
  end
end
