#json.error  'sample'

json.app do
  json.income_amount @response[:income_amount]
  json.expense_amount @response[:expense_amount]
end