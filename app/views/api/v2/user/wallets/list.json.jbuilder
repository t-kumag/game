json.wallets do
  json.array!(@responses) do |r|
    json.id r[:id]
    json.name r[:name]
    json.amount r[:amount]
    json.goals do
      r[:goals].blank? ? [] :
          json.array!(r[:goals]) do |g|
            json.current_amount g[:current_amount]
            json.name g[:name]
          end
    end
  end
end
