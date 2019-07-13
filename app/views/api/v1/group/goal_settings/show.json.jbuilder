json.app do
  json.goal_setting_id @response.id
  json.goal_id @response.goal_id
  json.at_user_bank_account_id @response.at_user_bank_account_id
  json.monthly_amount @response.monthly_amount
  json.first_amount @response.first_amount
end