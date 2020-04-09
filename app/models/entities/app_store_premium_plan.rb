class Entities::AppStorePremiumPlan < ApplicationRecord
  def self.all_plans
    list = {}
    self.all.map do |plan|
      list["#{Settings.app_store_bundle_id}.#{plan.product_id}"] = plan
  end
  list
  end
end