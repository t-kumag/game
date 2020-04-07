class CreateUserPurchases < ActiveRecord::Migration[5.2]
  def change
    create_table :user_purchases do |t|
      t.references :user, foreign_key: true
      t.platform
      t.transaction_id
      t.premium_plan_id
      t.status
      t.receipt
      t.purchase_at
      t.timestamps
    end
  end
end
