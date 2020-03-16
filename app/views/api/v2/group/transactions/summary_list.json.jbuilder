#json.error  'sample'

json.errors []
json.owner_summary do
  json.count @response[:owner][:count]
  json.percent @response[:owner][:percent]
  json.total_amount @response[:owner][:total_amount]
end

json.partner_summary do
  json.count @response[:partner][:count]
  json.percent @response[:partner][:percent]
  json.total_amount @response[:partner][:total_amount]
end

json.family_summary do
  json.count @response[:family][:count]
  json.percent @response[:family][:percent]
  json.total_amount @response[:family][:total_amount]
end
json.pair_diff_total @response[:pair_diff_total]
json.pair_total_amount @response[:pair_total_amount]
