class Entities::User < ApplicationRecord
  has_one :at_user

  has_many :access_grants, class_name: "Doorkeeper::AccessGrant",
          foreign_key: :resource_owner_id,
          dependent: :delete_all # or :destroy if you need callbacks
  has_many :access_tokens, class_name: "Doorkeeper::AccessToken",
          foreign_key: :resource_owner_id,
          dependent: :delete_all # or :destroy if you need callbacks

  def self.authenticate!(username, password)
      params = {
        email: username,
        crypted_password: Digest::MD5.hexdigest(password)
      }
      return self.find_by(params)
  end

#   def create_at_user
#     begin
#       at_user = AtUser.new(
#         {user_id: self.id}
#       )
#       at_user.password = at_user.generate_at_user_password
#       at_user.save!
#       params = {
#       at_user_id: at_user.at_user_id,
#       # at_user_password: at_user.password,
#       # at_user_email: at_user.at_user_email,
#       }
#       requester = AtAPIRequest::AtUser::CreateUser.new(params)
#       res = AtAPIClient.new(requester).request
#     return at_user
#     rescue AtAPIStandardError => api_err
#     rescue ActiveRecord::RecordInvalid => db_err            
#     rescue => exception
#     end
#   end
end
