json.app do
  if @current_user.present?
    json.user_id  @current_user.id
  end
  if @profile.present?
    json.gender  @profile.gender
    json.birthday  @profile.birthday
    json.has_child  @profile.has_child
  end
  if @profile.present? && @profile.push == true
    json.push  @profile.push
  else
    json.push  false
  end
  if @icon.present?
    json.img_url "#{Settings.s3_img_url}#{@icon.img_url}" if @icon.try(:img_url).present?
  end
end