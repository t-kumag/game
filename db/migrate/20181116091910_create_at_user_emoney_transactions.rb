class CreateAtUserEmoneyTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :at_user_emoney_transactions do |t|
      t.references :at_user, foreign_key: true

      t.timestamps
    end
  end
end
