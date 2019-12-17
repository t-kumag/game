json.pl_settings do
  json.pl_period_date @response[:pl_period_date]
  json.pl_type @response[:pl_type]
  json.group_pl_period_date @response[:group_pl_period_date]
  json.group_pl_type @response[:group_pl_type]
end