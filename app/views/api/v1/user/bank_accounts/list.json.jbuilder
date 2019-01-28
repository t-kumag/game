json.meta do
  json.error  'sample'
end

json.app do
  json.array!(@responses) do |r|
    json.account_id r[:id]
    json.name r[:fnc_nm]
    json.amount r[:balance]
    # json.error account[:error]
  end
end
