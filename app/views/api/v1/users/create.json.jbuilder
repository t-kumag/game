json.app do
  json.access_token @user.token
  json.access_token_expires_at @user.token_expires_at
end
