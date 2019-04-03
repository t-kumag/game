json.meta do
  #エラー時ハンドリングあってるかわからないので、あとからちゃんとやる。
  json.error @error if @error
end

json.app do
  json.goals do
    json.array! @goals
  end
end
