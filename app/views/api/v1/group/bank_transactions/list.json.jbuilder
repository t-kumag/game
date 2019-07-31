json.app do
  json.array!(@transactions) do |transaction|
    json.at_user_bank_transaction_id transaction.at_user_bank_transaction_id
    json.amount transaction.amount
    json.used_date transaction.used_date.strftime('%Y-%m-%d %H:%M:%S')
    json.used_location transaction.used_location
    json.is_shared transaction.share
    json.at_transaction_category_id transaction.at_transaction_category_id
    json.category_name1 @categories.find{|c| c[:id]==transaction.at_transaction_category_id }[:category_name1]
    json.category_name2 @categories.find{|c| c[:id]==transaction.at_transaction_category_id }[:category_name2]
  end
end
