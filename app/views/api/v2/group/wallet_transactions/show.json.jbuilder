json.transactions do
  json.amount @response[:amount]
  json.used_date @response[:used_date].strftime('%Y-%m-%d %H:%M:%S')
  json.used_location @response[:used_location]
  json.memo @response[:memo]
  json.user_id @response[:user_id]
  json.is_account_shared @response[:is_account_shared]
  json.is_shared @response[:is_shared]
  json.at_transaction_category_id @response[:at_transaction_category_id]
  json.category_name1 @response[:category_name1]
  json.category_name2 @response[:category_name2]
  json.payment_name @response[:payment_name]
  json.transaction_id @response[:transaction_id]
  json.payment_method_id @response[:payment_method_id]
  json.payment_method_type @response[:payment_method_type]
end