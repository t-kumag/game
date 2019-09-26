json.app do
  json.transactions do
    json.array!(@transactions[:user_distributed_transaction]) do |transaction|
      json.at_user_bank_transaction_id transaction.at_user_bank_transaction_id
      json.amount transaction.amount
      json.used_date transaction.used_date.strftime('%Y-%m-%d %H:%M:%S')
      json.used_location transaction.used_location
      json.user_id transaction.user_id
      json.is_account_shared @transactions[:is_account_shared]
      json.is_shared transaction.share
      json.at_transaction_category_id transaction.at_transaction_category_id
      json.category_name1 transaction.at_transaction_category.category_name1
      json.category_name2 transaction.at_transaction_category.category_name2
      json.transaction_id transaction.at_user_bank_transaction_id
    end
  end
  json.prev_from_date @transactions[:prev_from_date]
end
