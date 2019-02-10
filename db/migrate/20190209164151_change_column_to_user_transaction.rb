class ChangeColumnToUserTransaction < ActiveRecord::Migration[5.2]
  def change
    remove_column :user_transactions, :owner
    add_column :user_transactions, :is_share, :boolean
  end
end
