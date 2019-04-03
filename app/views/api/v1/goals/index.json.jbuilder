json.meta do
  json.error  'sample'
end

json.app do
  json.goals do
    json.array! @goals
  end
end
