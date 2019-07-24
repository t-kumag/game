#json.error  'sample'

json.app do
  json.array!(@responses) do |r|
      json.account_id r[:id]
      json.name r[:name]
      json.amount r[:amount]
      json.fnc_id r[:fnc_id]
      json.error ""
  end
end
