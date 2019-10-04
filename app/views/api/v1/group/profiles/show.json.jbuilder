json.app do
  if @profile.present?
    json.user_id  @current_user.id
    json.partner_id  @current_user.partner_user.id
    json.gender  @profile.gender
    json.birthday  @profile.birthday
    json.has_child  @profile.has_child
  end
  if @icon.present?
    json.img_url "#{Settings.s3_img_url}#{@icon.img_url}" if @icon.try(:img_url).present?
  end
end