#json.error  'sample'

json.app do
  json.array!(@transactions) do |transaction|
    json.transaction_id transaction.at_user_emoney_transaction_id
    json.amount transaction.amount
    json.date transaction.at_user_emoney_transaction.used_date.strftime('%Y-%m-%d %H:%M:%S')
    json.description transaction.at_user_emoney_transaction.description
  end
end
