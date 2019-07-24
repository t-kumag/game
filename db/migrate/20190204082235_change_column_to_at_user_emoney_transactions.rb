class ChangeColumnToAtUserEmoneyTransactions < ActiveRecord::Migration[5.2]
  def change
    remove_column :at_user_emoney_transactions, :branch_desc
  end
end
