json.app do
  json.goals do
    json.goal_id @response[:id]
    json.goal_type_id @response[:goal_type_id]
    json.name @response[:name]
    json.img_url @response[:img_url]
    json.goal_amount @response[:goal_amount]
    json.current_amount @response[:current_amount]
    json.goal_difference_amount @response[:goal_difference_amount]
    json.start_date @response[:start_date]
    json.end_date @response[:end_date]
  end
  json.goal_settings do
    json.array!(@response[:goal_settings]) do |r|
      json.goal_setting_id r.id
      json.at_user_bank_account_id r.at_user_bank_account_id
      json.monthly_amount r.monthly_amount
      json.first_amount r.first_amount
    end
  end
end