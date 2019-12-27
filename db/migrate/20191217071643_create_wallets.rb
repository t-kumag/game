class CreateWallets < ActiveRecord::Migration[5.2]
  def change
    create_table :wallets do |t|
      t.references :user, foreign_key: true
      t.string :name, default: nil
      t.integer :initial_balance, default: 0, null: false
      t.integer :balance, default: 0, null: false
      t.integer :group_id
      t.boolean :share, default: 0, null: false
      t.timestamps
      t.datetime :deleted_at
    end
  end
end
