class CreateAppStorePremiumPlans < ActiveRecord::Migration[5.2]
  def change
    create_table :app_store_premium_plans do |t|
      t.title
      t.description
      t.status
      t.order_key
      t.timestamps
    end
  end
end
