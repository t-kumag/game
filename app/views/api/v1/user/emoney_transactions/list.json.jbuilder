json.meta do
  json.error  'sample'
end

json.app do
  json.array!(@transactions) do |transaction|
    json.transaction_id transaction.id
    json.amount transaction.amount
    json.date transaction.date
    json.description transaction.description
  end
end
