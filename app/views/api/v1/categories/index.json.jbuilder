json.app do
  json.at_grouped_categories(@responses) do |response|
    json.at_grouped_category_id response[:at_grouped_category_id]
    json.at_grouped_category_name response[:at_grouped_category_name]
    json.at_transaction_categories response[:at_transaction_categories]
  end
end
