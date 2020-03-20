json.owner do
  json.count @response[:owner][:count]
  json.rate @response[:owner][:rate]
  json.amount @response[:owner][:amount]
end

json.partner do
  json.count @response[:partner][:count]
  json.rate @response[:partner][:rate]
  json.amount @response[:partner][:amount]
end

json.family do
  json.count @response[:family][:count]
  json.rate @response[:family][:rate]
  json.amount @response[:family][:amount]
end
json.owner_partner_diff_amount @response[:owner_partner_diff_amount]
json.total_amount @response[:total_amount]
