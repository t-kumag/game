class CreatePairingRequestTable < ActiveRecord::Migration[5.2]
  def change
    create_table :pairing_requests do |t|
      t.references :from_user
      t.references :to_user
      t.references :group, foreign_key: true
      t.string :token
      t.integer :status
      t.timestamps
    end
    add_foreign_key :pairing_requests, :users, column: :from_user_id
    add_foreign_key :pairing_requests, :users, column: :to_user_id
  end
end
