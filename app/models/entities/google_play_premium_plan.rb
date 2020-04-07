class Entities::GooglePlayPremiumPlan < ApplicationRecord
  def self.all_plans
    list = {}
    self.all.map do |plan|
      list["#{plan.product_id}"] = plan
    end
    list
  end
end