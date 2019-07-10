json.app do
  json.goals_status do
    json.goal_id @response.id
    json.goal_type_id @response.goal_type_id
    json.name @response.name
    json.img_url @response.img_url
    json.goal_amount @response.goal_amount
    json.current_amount @response.current_amount
    json.goal_difference_amount @response.goal_amount - @response.current_amount
    json.start_date @response.start_date
    json.end_date @response.end_date
  end
end