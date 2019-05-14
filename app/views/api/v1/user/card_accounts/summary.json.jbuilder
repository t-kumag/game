json.meta do
  json.error  'sample'
end

json.app do
  json.current_month_payment @response[:amount].to_f
end
