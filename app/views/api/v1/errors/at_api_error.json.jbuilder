json.app Hash

json.errors do
  json.array!(@errors) do |error|
    json.code error[:code]
    json.message error[:message]
  end
end
