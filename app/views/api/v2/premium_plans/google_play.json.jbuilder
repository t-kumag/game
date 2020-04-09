json.premium_plans(@responses) do |response|
  json.id response[:id]
  json.product_id response[:product_id]
  json.name response[:name]
  json.description response[:description]
end
