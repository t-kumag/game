class CreateUserManuallyCreatedTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_manually_created_transactions do |t|
      t.references :user, foreign_key: true
      t.references :group, foreign_key: true
      t.references :at_transaction_category, index: { name: 'index_u_m_c_t_on_at_transaction_category_id' }, foreign_key: true
      t.references :payment_method, index: { name: 'index_u_m_c_t_on_payment_method_id' }, foreign_key: true
      t.date :used_date, null: false
      t.string :title
      t.integer :amount
      t.string :used_location
      t.timestamps
    end
  end
end
