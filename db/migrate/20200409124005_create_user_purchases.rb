class CreateUserPurchases < ActiveRecord::Migration[5.2]
  def change
    create_table :user_purchases do |t|
      t.references :user, foreign_key: true
      t.references :app_store_premium_plan, foreign_key: true
      t.references :google_play_premium_plan, foreign_key: true
      t.string :order_transaction_id, null: false
      t.datetime :subscription_start_at, null: false
      t.datetime :subscription_expires_at, null: false
      t.datetime :purchase_at, null: false
      t.timestamps
    end
  end
end
