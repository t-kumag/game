json.app do
  # json.url @url
  json.url @response[:url]
  json.chnl_id @response[:chnl_id]
  json.token_key @response[:token_key]
end
