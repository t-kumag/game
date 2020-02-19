json.stock_accounts do
  json.array!(@responses) do |r|
    json.account_id r[:id]
    json.name r[:name]
    json.balance r[:balance]
    json.deposit_balance r[:deposit_balance]
    json.profit_loss_amount r[:profit_loss_amount]
    json.fnc_id r[:fnc_id]
    json.last_rslt_cd r[:last_rslt_cd]
    json.last_rslt_msg r[:last_rslt_msg]
  end
end