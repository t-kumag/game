class CreateGooglePlayPremiumPlans < ActiveRecord::Migration[5.2]
  def change
    create_table :google_play_premium_plans do |t|
      t.string :product_id, null: false
      t.string :name, null: false
      t.string :description, null: false
      t.timestamps
    end
  end
end
