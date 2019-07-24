#json.error  'sample'

json.app do
  json.token @pairing_request.token
  json.token_expires_at @pairing_request.token_expires_at
end
