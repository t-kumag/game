class Entities::BalanceLog < ApplicationRecord
  def self.insert(params)
    params.each do |v|
      self.create!(v)
    end
  end
end
