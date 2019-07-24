json.app Hash

json.errors do
  json.array!(@errors) do |error|
    json.resource error[:resource]
    json.field error[:field]
    json.code error[:code]
  end
end
