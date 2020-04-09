class CreateUserGooglePlayPurchaseLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :user_google_play_purchase_logs do |t|
      t.references :user, foreign_key: true
      t.string :order_id, null: false
      t.references :google_play_premium_plan, index: { name: 'index_u_g_p_p_l_on_google_play_premium_plan_id' }, foreign_key: true
      t.boolean :auto_renewing, default: 0, null: false
      t.datetime :start_time_millis, null: false
      t.datetime :expiry_time_millis, null: false
      t.string :purchase_token, null: false
      t.timestamps
    end
  end
end
