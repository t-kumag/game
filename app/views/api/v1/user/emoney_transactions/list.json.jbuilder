#json.error  'sample'

json.app do
  json.array!(@transactions) do |transaction|
    json.transaction_id transaction.id
    json.amount transaction.amount.to_f
    json.date transaction.date.strftime('%Y-%m-%d %H:%M:%S')
    json.description transaction.description
  end
end
