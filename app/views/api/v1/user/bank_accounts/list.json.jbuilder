json.meta do
  json.error  'sample'
end

json.app do
  json.array!(@response[:accounts]) do |account|
    json.account_id account[:account_id]
    json.name account[:name]
    json.amount account[:amount]
    json.error account[:error]
  end
end

