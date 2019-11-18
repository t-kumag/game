json.meta do
  json.error @error if @error
end
json.activities do
  json.array!(@activities) do |a|
    json.day a.created_at.strftime('%Y-%m-%d')
    json.type ""
    json.url a.url
    json.message a.message
  end
end
