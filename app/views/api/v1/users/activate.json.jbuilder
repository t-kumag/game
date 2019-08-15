json.error @error if @error

json.app do
  json.token @response[:token]
  json.expires_at @response[:token_expires_at]
end
