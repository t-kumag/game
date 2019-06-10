json.meta do
  json.error @error if @error
end
json.activities do
  json.array!(@activities) do |n|
    json.day n[:day]
    json.type n[:type]
    json.count n[:count]
  end
end
