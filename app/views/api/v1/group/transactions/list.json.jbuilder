#json.error  'sample'

json.errors []
json.app do
  json.array!(@response) do |r|
    json.at_user_bank_account_id           r[:at_user_bank_account_id] if r[:at_user_bank_account_id].present?
    json.at_user_card_account_id           r[:at_user_card_account_id] if r[:at_user_card_account_id].present?
    json.at_user_emoney_service_account_id r[:at_user_emoney_service_account_id] if r[:at_user_emoney_service_account_id].present?

    json.amount r[:amount]
    json.used_date r[:used_date].strftime('%Y-%m-%d %H:%M:%S')
    json.used_location r[:used_location]
    json.type r[:type]
    json.is_shared r[:is_shared]
    json.transaction_id r[:transaction_id]
    json.at_transaction_category_id r[:at_transaction_category_id]
  end
end
