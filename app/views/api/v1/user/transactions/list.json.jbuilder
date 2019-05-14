json.meta do
  json.error  'sample'
end

json.app do
  json.array!(@responses) do |r|
      json.transaction_id r[:id]
      json.date r[:date]
      json.name r[:name]
      json.amount r[:amount].to_f
      json.error ""
  end
end
