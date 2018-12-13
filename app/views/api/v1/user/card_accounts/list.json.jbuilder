json.meta do
    json.error ''
end

json.app do
    json.array!(@card_accounts) do |account|
        json.account_id account.id
        json.name account.fnc_nm
        json.amount account.amount
        # json.error account[:error]
    end
end
