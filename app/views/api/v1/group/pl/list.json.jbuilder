#json.error  'sample'

json.app do
  json.array!(@response) do |r|
    json.category_id r['at_transaction_category_id']
    json.category_name1 r['category_name1']
    json.category_name2 r['category_name2']
    json.income_amount r['amount_receipt']
    json.expense_amount r['amount_payment']
  end
end
