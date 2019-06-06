json.meta do
  json.error @error if @error
end

json.notices do
  json.array!(@notices) do |n|
    json.id n[:id]
    json.title n[:title]
    json.date n[:date]
    json.url "https://beta2.osidori-dev.com/api/v1/timeline/notices/" + n[:id].to_s
  end
end
