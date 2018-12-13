json.meta do
  json.error  'sample'
end

json.app do
  json.amount @response[:amount]
end
