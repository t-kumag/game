#json.error  'sample'

json.app do
  json.current_month_payment @response[:amount].to_f
end
