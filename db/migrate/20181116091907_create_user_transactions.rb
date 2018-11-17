class CreateUserTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_transactions do |t|
      t.integer :log_user_id
      t.integer :group_id
      t.string :owner

      t.integer :at_user_bank_transaction_id
      t.integer :at_user_card_transaction_id
      t.integer :at_user_emoney_transaction_id
      t.integer :user_manually_created_transaction_id

      # t.string :before_distributing_transaction_type # 一つ前のtransaction
      # t.integer :before_distributing_transaction_id # 
      t.timestamps
    end
  end
end
