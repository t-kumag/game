class CreateAtUserCardAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :at_user_card_accounts do |t|
      t.references :at_user, foreign_key: true
      t.references :at_card_id, foreign_key: true
      t.boolean :share

      t.timestamps
    end
  end
end
