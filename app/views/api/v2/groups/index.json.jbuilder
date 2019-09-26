json.meta do
  json.error @error if @error
end

json.app do
  json.groups do
    json.array! @groups
  end
end
