json.meta do
  json.error  'sample'
end

json.app do
  json.array!(@responses) do |r|
      json.account_id r[:id]
      json.name r[:name]
      json.amount r[:amount]
      json.error ""
  end
end
