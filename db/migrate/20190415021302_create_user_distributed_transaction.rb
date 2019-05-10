class CreateUserDistributedTransaction < ActiveRecord::Migration[5.2]
  def change
    create_table :user_distributed_transactions do |t|
      t.references :user, foreign_key: true
      t.references :group, foreign_key: true
      t.boolean :share
      t.date :used_date, null: false
      t.references :at_user_bank_transaction, index: { name: 'index_u_d_t_on_at_user_bank_transaction_id' }, foreign_key: true
      t.references :at_user_card_transaction, index: { name: 'index_u_d_t_on_at_user_card_transaction_id' }, foreign_key: true
      t.references :at_user_emoney_transaction, index: { name: 'index_u_d_t_on_at_user_emoney_transaction_id' }, foreign_key: true
      t.references :user_manually_created_transaction, index: { name: 'index_u_d_t_on_user_manually_created_transaction_id' }, foreign_key: true
      t.timestamps
    end
  end
end
