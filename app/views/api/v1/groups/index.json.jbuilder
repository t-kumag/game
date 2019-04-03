json.meta do
  json.error  'sample'
end

json.app do
  json.goals do
    json.array! @groups
  end
end
