json.errors do
  json.code "001001"
  json.message "account status is temporary registration."
end

json.app do
  json.email @response[:email]
  json.email_authenticated @response[:email_authenticated]
end
