json.error @error if @error.present?

json.app do
  json.id @response.id
  json.at_transaction_category do
    json.id @category_map[@response.at_transaction_category.id]['id']
    json.category_name1 @category_map[@response.at_transaction_category.id]['category_name1']
    json.category_name2 @category_map[@response.at_transaction_category.id]['category_name2']

  end
  json.used_date @response.used_date
  json.title @response.title
  json.amount @response.amount
  json.is_shared @response.user_distributed_transaction.share
  json.is_ignored @response.user_distributed_transaction.ignore
  json.used_location @response.used_location
  json.payment_method_id @response.payment_method_id
  json.payment_method_type @response.payment_method_type
  json.memo @response.memo
end
