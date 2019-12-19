json.payment_methods(@responses) do |response|
  json.id response[:id]
  json.type response[:type]
  json.name response[:name]
end
