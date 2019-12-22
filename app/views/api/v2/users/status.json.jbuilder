json.user_status do
  json.user_id @current_user.id
  json.mail_registered @current_user.email.present?
  json.mail_authenticated @current_user.email_authenticated
  json.finance_registered @response[:finance_registered]
  json.goal_created @response[:goal_created]
  json.transaction_shared @response[:transaction_shared]
  json.finance_shared @response[:finance_shared]
  json.paired @current_user.partner_user.present?
  json.group_goal_created @response[:group_goal_created]
  json.group_transaction_shared @response[:group_transaction_shared]
  json.group_finance_shared @response[:group_finance_shared]
end