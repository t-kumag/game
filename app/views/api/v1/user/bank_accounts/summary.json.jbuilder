json.meta do
  json.error  'sample'
end

json.app do
  json.amount @response[:amount]
end

# {"tweet": {"text": "テキスト1", "title": "タイトル1"} }
