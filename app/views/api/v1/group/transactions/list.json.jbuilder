#json.error  'sample'

json.errors []
json.app do
  json.array!(@response) do |r|
      json.amount r[:amount]
      json.used_date r[:used_date].strftime('%Y-%m-%d %H:%M:%S')
      json.used_location r[:used_location]
      json.type r[:type]
      json.transaction_id r[:transaction_id]
  end
end
