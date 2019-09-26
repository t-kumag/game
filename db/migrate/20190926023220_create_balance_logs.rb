class CreateBalanceLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :balance_logs do |t|
      t.references :at_user_bank_account, index: { name: 'index_b_l_on_at_user_bank_account_id' }, foreign_key: true
      t.references :at_user_emoney_service_account, index: { name: 'index_b_l_on_at_user_emoney_service_account_id' }, foreign_key: true
      t.integer :amount, default: 0, null: false
      t.datetime :date, null: false
      t.timestamps
    end
  end
end