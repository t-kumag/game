json.error @error if @error.present?

json.app do
  json.id @response.id
  json.at_transaction_category do
    json.id @response.at_transaction_category.id
    json.category_name1 @response.at_transaction_category.category_name1
    json.category_name2 @response.at_transaction_category.category_name2
  end
  json.used_date @response.used_date
  json.title @response.title
  json.amount @response.amount
  json.is_shared @response.user_distributed_transaction.share
  json.used_location @response.used_location
end
