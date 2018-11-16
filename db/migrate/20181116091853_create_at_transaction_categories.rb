class CreateAtTransactionCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :at_transaction_categories do |t|

      t.timestamps
    end
  end
end
