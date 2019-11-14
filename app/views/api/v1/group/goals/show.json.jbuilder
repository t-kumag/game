json.app do
  json.goals do
    json.goal_id @response[:id]
    json.goal_type_id @response[:goal_type_id]
    json.name @response[:name]
    json.img_url "#{Settings.s3_img_url}#{@response[:img_url]}" if @response[:img_url].present?
    json.goal_amount @response[:goal_amount]
    json.current_amount @response[:current_amount]
    json.goal_difference_amount @response[:goal_difference_amount]
    json.start_date @response[:start_date]
    json.end_date @response[:end_date]
    json.progress_monthly do
      json.progress @response[:progress_monthly][:progress]
      json.icon @response[:progress_monthly][:icon]
    end
  end
  json.owner_current_amount do
    json.monthly_amount @response[:owner_current_amount][:monthly_amount]
    json.first_amount @response[:owner_current_amount][:first_amount]
    json.add_amount @response[:owner_current_amount][:add_amount]
    json.current_amount @response[:owner_current_amount][:current_amount]
  end
  json.partner_current_amount do
    json.monthly_amount @response[:partner_current_amount][:monthly_amount]
    json.first_amount @response[:partner_current_amount][:first_amount]
    json.add_amount @response[:partner_current_amount][:add_amount]
    json.current_amount @response[:partner_current_amount][:current_amount]
  end
  json.goal_settings do
    json.array!(@response[:goal_settings]) do |r|
      json.goal_setting_id r.id
      json.user_id r.user_id
      json.at_user_bank_account_id r.at_user_bank_account_id
      json.monthly_amount r.monthly_amount
      json.first_amount r.first_amount
    end
  end
end