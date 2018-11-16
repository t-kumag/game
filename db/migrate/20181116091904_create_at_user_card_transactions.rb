class CreateAtUserCardTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :at_user_card_transactions do |t|

      t.timestamps
    end
  end
end
