json.meta do
  json.error @error if @error
end

json.notices do
  json.unread_total_count @unread_total_count
end
