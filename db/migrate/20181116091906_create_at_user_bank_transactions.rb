class CreateAtUserBankTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :at_user_bank_transactions do |t|

      t.timestamps
    end
  end
end
