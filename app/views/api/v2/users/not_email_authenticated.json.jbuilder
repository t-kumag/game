json.user_status do
  json.user_id @current_user.id
  json.mail_registered @current_user.email.present?
  json.mail_authenticated @current_user.email_authenticated
  json.finance_registered false
  json.goal_created false
  json.transaction_shared false
  json.finance_shared false
  json.paired false
  json.group_goal_created false
  json.group_transaction_shared false
  json.group_finance_shared false
end