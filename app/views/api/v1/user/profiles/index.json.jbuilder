json.meta do
  json.error @error if @error
end

json.app do
  json.gender  @profile.gender
  json.birthday  @profile.birthday
  json.has_child  @profile.has_child
  json.push  @profile.push
end