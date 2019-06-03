json.error @error if @error

json.app do
  json.array!(@responses) do |r|
    json.goals do
      json.goal_id r.id
      json.goal_type_id r.goal_type_id
      json.name r.name
      json.img_url r.img_url
      json.goal_amount r.goal_amount
      json.current_amount r.current_amount
      json.start_date r.start_date
      json.end_date r.end_date
    end
    json.goal_settings do
      json.array!(r.goal_settings) do |s|
        json.goal_setting_id s.id
        json.at_user_bank_account_id s.at_user_bank_account_id
        json.monthly_amount s.monthly_amount
        json.first_amount s.first_amount
      end
    end
  end
end