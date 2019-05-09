json.error  'sample'

json.app do
  json.array!(@response) do |r|
    json.category_id r['at_transaction_category_id']
    json.name '食費' #TODO　カテゴリー名
    json.income_amount r['amount_receipt'].to_f
    json.expense_amount r['amount_payment'].to_f
  end
end
