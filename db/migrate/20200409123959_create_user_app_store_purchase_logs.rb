class CreateUserAppStorePurchaseLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :user_app_store_purchase_logs do |t|
      t.references :user, foreign_key: true
      t.string :transaction_id
      t.references :app_store_premium_plan, foreign_key: true
      t.string :product_id, null: false
      t.datetime :purchase_date, null: false
      t.datetime :expires_date, null: false
      t.boolean :is_trial_period, default: 0, null: false
      t.text :receipt, null: false
      t.timestamps
    end
  end
end
