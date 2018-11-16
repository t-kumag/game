class CreateAtUserBankAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :at_user_bank_accounts do |t|
      t.references :at_user, foreign_key: true
      t.references :at_bank_id, foreign_key: true
      t.decimal :balance, precision: 10, scale: 2
      t.boolean :share

      t.timestamps
    end
  end
end
