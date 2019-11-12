#json.error  'sample'

json.app do
  json.array!(@responses) do |r|
      json.account_id r[:id]
      json.name r[:name]
      json.amount r[:amount]
      json.fnc_id r[:fnc_id]
      json.last_rslt_cd r[:last_rslt_cd]
      json.last_rslt_msg r[:last_rslt_msg]
      json.goals do
        r[:goals].blank? ? [] : 
        json.array!(r[:goals]) do |g| 
          json.current_amount g[:current_amount]
          json.name g[:name]
        end
      end
  end
end
