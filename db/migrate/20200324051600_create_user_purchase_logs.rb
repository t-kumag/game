class CreateUserPurchaseLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :user_purchase_logs do |t|
      t.references :user_purchase, foreign_key: true
      t.references :user, foreign_key: true
      t.platform
      t.platform_transaction_id
      t.premium_plan_id
      t.status
      t.receipt
      t.purchase_at
      t.timestamps
    end
  end
end
