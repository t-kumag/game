#json.error  'sample'

json.app do
  json.token @pairing_request.token
  json.pairing_token_expires_at @pairing_request.pairing_token_expires_at
end
