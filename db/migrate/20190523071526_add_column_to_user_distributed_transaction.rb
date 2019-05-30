class AddColumnToUserDistributedTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :user_distributed_transactions, :used_location, :string
    add_column :user_distributed_transactions, :amount, :integer
    add_reference :user_distributed_transactions, :at_transaction_category, index: { name: 'index_u_d_t_on_at_transaction_category_id' }, foreign_key: true
  end
end
