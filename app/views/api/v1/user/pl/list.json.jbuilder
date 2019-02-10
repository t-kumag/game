json.meta do
  json.error  'sample'
end

json.app do
  
  json.spending do
    json.array!(@response[:spending_categories]) do |r|
      json.category_id r[:category_id]
      json.name r[:name]
      json.amount r[:amount]
    end
  end

  json.income do
    json.array!(@response[:income_categories]) do |r|
      json.category_id r[:category_id]
      json.name r[:name]
      json.amount r[:amount]
    end
  end

end
