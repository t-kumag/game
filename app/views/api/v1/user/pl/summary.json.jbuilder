json.meta do
  json.error  ''
end

json.app do
  json.income_amount @response[:income_amount]
  json.expense_amount @response[:spending_amount]
end
