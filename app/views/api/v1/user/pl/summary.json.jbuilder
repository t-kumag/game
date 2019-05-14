json.meta do
  json.error  ''
end

json.app do
  json.income_amount @response[:income_amount].to_f
  json.expense_amount @response[:expense_amount].to_f
end