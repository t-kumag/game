#json.error  'sample'

json.errors []
json.app do
  json.owner_expense do
    json.array!(@response[:owner]) do |r|
      json.at_user_bank_account_id           r[:at_user_bank_account_id] if r[:at_user_bank_account_id].present?
      json.at_user_card_account_id           r[:at_user_card_account_id] if r[:at_user_card_account_id].present?
      json.at_user_emoney_service_account_id r[:at_user_emoney_service_account_id] if r[:at_user_emoney_service_account_id].present?
      json.wallet_id r[:wallet_id] if r[:wallet_id].present?

      json.user_id r[:user_id]
      json.amount r[:amount]
      json.used_date r[:used_date].strftime('%Y-%m-%d %H:%M:%S')
      json.used_location r[:used_location]
      json.memo r[:memo]
      json.type r[:type]
      json.is_shared r[:is_shared]
      json.is_account_shared r[:is_account_shared]
      json.transaction_id r[:transaction_id]
      json.at_transaction_category_id r[:at_transaction_category_id]
      json.is_ignored r[:is_ignored]
    end
  end

  json.partner_expense do
    json.array!(@response[:partner]) do |r|
      json.at_user_bank_account_id           r[:at_user_bank_account_id] if r[:at_user_bank_account_id].present?
      json.at_user_card_account_id           r[:at_user_card_account_id] if r[:at_user_card_account_id].present?
      json.at_user_emoney_service_account_id r[:at_user_emoney_service_account_id] if r[:at_user_emoney_service_account_id].present?
      json.wallet_id r[:wallet_id] if r[:wallet_id].present?

      json.user_id r[:user_id]
      json.amount r[:amount]
      json.used_date r[:used_date].strftime('%Y-%m-%d %H:%M:%S')
      json.used_location r[:used_location]
      json.memo r[:memo]
      json.type r[:type]
      json.is_shared r[:is_shared]
      json.is_account_shared r[:is_account_shared]
      json.transaction_id r[:transaction_id]
      json.at_transaction_category_id r[:at_transaction_category_id]
      json.is_ignored r[:is_ignored]
    end
  end

  json.family_expense do
    json.array!(@response[:family]) do |r|
      json.at_user_bank_account_id           r[:at_user_bank_account_id] if r[:at_user_bank_account_id].present?
      json.at_user_card_account_id           r[:at_user_card_account_id] if r[:at_user_card_account_id].present?
      json.at_user_emoney_service_account_id r[:at_user_emoney_service_account_id] if r[:at_user_emoney_service_account_id].present?
      json.wallet_id r[:wallet_id] if r[:wallet_id].present?

      json.user_id r[:user_id]
      json.amount r[:amount]
      json.used_date r[:used_date].strftime('%Y-%m-%d %H:%M:%S')
      json.used_location r[:used_location]
      json.memo r[:memo]
      json.type r[:type]
      json.is_shared r[:is_shared]
      json.is_account_shared r[:is_account_shared]
      json.transaction_id r[:transaction_id]
      json.at_transaction_category_id r[:at_transaction_category_id]
      json.is_ignored r[:is_ignored]
    end
  end
end
