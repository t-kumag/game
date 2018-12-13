json.meta do
  json.error  'sample'
end

json.app do
  json.array!(@bank_accounts) do |account|
    json.account_id account.id
    json.name account.fnc_nm
    json.amount account.balance
    # json.error account[:error]
  end
end
