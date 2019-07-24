json.meta do
  json.error @error if @error
end

json.app do
  json.user_id  @profile.user_id
  json.gender  @profile.gender
  json.birthday  @profile.birthday
  json.has_child  @profile.has_child
  json.push  @profile.push
  json.img_url @icon.img_url if @icon.present?
end