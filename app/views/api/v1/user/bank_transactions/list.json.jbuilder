json.meta do
  json.error  'sample'
end

json.app do
  json.array!(@transactions) do |transaction|
    json.transaction_id transaction.id
    json.amount_receipt transaction.amount_receipt
    json.amount_payment transaction.amount_payment
    json.trade_date transaction.trade_date
    json.description transaction.description1
    # json.error account[:error]
  end
end

# {"tweet": {"text": "テキスト1", "title": "タイトル1"} }
