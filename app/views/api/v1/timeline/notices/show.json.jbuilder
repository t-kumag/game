json.meta do
  json.error @error if @error
end

json.notices do
  json.title @notice[:title]
  json.description @notice[:description]
end
