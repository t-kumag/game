class ChangeColumnToUserDistributedTransactions < ActiveRecord::Migration[5.2]
  def change
    add_index :user_distributed_transactions, [:user_id, :at_user_bank_transaction_id], unique: true, name: :index_u_d_t_on_user_id_and_at_user_bank_transaction_id
    add_index :user_distributed_transactions, [:user_id, :at_user_card_transaction_id], unique: true, name: :index_u_d_t_on_user_id_and_at_user_card_transaction_id
    add_index :user_distributed_transactions, [:user_id, :at_user_emoney_transaction_id], unique: true, name: :index_u_d_t_on_user_id_and_at_user_emoney_transaction_id
    add_index :user_distributed_transactions, [:user_id, :user_manually_created_transaction_id], unique: true, name: :index_u_d_t_on_user_id_and_user_manually_created_transaction_id
  end
end