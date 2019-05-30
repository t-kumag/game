class ChangeUsedDateToAtUserCardTransactions < ActiveRecord::Migration[5.2]
  def up
    change_column :at_user_card_transactions, :used_date, :datetime
  end

  def down
    change_column :at_user_card_transactions, :used_date, :date
  end
end
