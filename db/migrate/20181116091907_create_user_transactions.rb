class CreateUserTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_transactions do |t|
      t.integer :log_user
      t.integer :group_id
      t.string :distribution_result

      t.timestamps
    end
  end
end
