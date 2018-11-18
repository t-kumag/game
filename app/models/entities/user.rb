class Entities::User < ApplicationRecord
  has_one :at_user

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
