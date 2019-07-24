# == Schema Information
#
# Table name: at_user_tokens
#
#  id         :bigint(8)        not null, primary key
#  at_user_id :bigint(8)
#  token      :string(255)
#  expires_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Entities::AtUserToken < ApplicationRecord
  acts_as_paranoid
  belongs_to :at_user, inverse_of: :at_user_tokens

  validates :at_user_id, presence: true

  def self.create_token(at_user)
    params = {
      at_user_id: at_user.at_user_id,
      at_user_password: at_user.at_user_password,
    }
    requester = AtAPIRequest::AtUser::GetToken.new(params)
    begin
      res = AtAPIClient.new(requester).request
      at_user_token = self.new({
        at_user_id: at_user.id,
        token: res["TOKEN_KEY"],
        expires_at: res["EXPI_DT"], # TODO
      })
      at_user_token.save!
      return at_user_token
    rescue AtAPIStandardError => api_err
      raise api_err
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
    end
  end

  def refresh
    at_user = Entities::AtUser.find(at_user_id)
    params = {
      at_user_id: at_user.at_user_id,
      at_user_password: at_user.at_user_password,
    }
    requester = AtAPIRequest::AtUser::GetToken.new(params)
    begin
      res = AtAPIClient.new(requester).request
      self.token = res["TOKEN_KEY"]
      self.expires_at = res["EXPI_DT"], # TODO
      self.save!
    rescue AtAPIStandardError => api_err
      raise api_err
    rescue ActiveRecord::RecordInvalid => db_err
      raise db_err
    rescue => exception
    end
  end

  def disabled?
    if expires_at > (Time.new - 2.hours)
      true
    else
      if expires_at <= (Time.new - 2.hours) && expires_at <= (Time.new - 2.hours)
      else
        params = {
          at_user_id: self.at_user_id,
          at_user_token: self.token,
        }
        requester = AtAPIRequest::AtUser::GetTokenStatus.new(params)
        begin
          res = AtAPIClient.new(requester).request
          if "0" == res["STATUS"]
            # self.token = res["TOKEN_KEY"]
            # self.expires_at = res["EXPI_DT"]
            # self.save!
            return false
          else
            return true
          end
        rescue AtAPIStandardError => api_err
          raise api_err
        rescue ActiveRecord::RecordInvalid => db_err
          raise db_err
        rescue => exception
        end
      end
    end
  end
end
