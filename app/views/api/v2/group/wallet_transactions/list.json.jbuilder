json.transactions do
  json.array!(@transactions[:user_distributed_transaction]) do |transaction|
    json.user_manually_created_transaction_id transaction.user_manually_created_transaction_id
    json.amount transaction.amount
    json.used_date transaction.used_date.strftime('%Y-%m-%d %H:%M:%S')
    json.used_location transaction.used_location
    json.memo transaction.memo
    json.type transaction.type
    json.user_id transaction.user_id
    json.is_account_shared @transactions[:is_account_shared]
    json.is_shared transaction.share
    json.is_ignored transaction.ignore
    json.at_transaction_category_id @category_map[transaction.at_transaction_category_id]['id']
    json.category_name1 @category_map[transaction.at_transaction_category_id]['category_name1']
    json.category_name2 @category_map[transaction.at_transaction_category_id]['category_name2']
    json.transaction_id transaction.user_manually_created_transaction_id
    json.payment_method_id transaction.user_manually_created_transaction.payment_method_id
    json.payment_method_type transaction.user_manually_created_transaction.payment_method_type
  end
end
json.next_transaction_used_date @transactions[:next_transaction_used_date]
