json.transactions do
  json.array!(@transactions[:user_distributed_transaction]) do |transaction|
    json.user_manually_created_transaction_id transaction.id
    json.amount transaction.amount
    json.used_date transaction.used_date.strftime('%Y-%m-%d %H:%M:%S')
    json.used_location transaction.used_location
    json.user_id transaction.user_id
    json.is_account_shared @transactions[:is_account_shared]
    json.is_shared transaction.share
    json.at_transaction_category_id transaction.at_transaction_category_id
    json.category_name1 transaction.at_transaction_category.category_name1
    json.category_name2 transaction.at_transaction_category.category_name2
    json.transaction_id transaction.user_manually_created_transaction_id
    json.payment_method_id transaction.user_manually_created_transaction.payment_method_id
    json.payment_method_type transaction.user_manually_created_transaction.payment_method_type
  end
end
json.next_transaction_used_date nil
