json.errors @error_response

json.app do
  json.email @response[:email]
  json.email_authenticated @response[:email_authenticated]
end
