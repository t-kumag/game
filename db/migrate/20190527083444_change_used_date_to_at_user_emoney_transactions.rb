class ChangeUsedDateToAtUserEmoneyTransactions < ActiveRecord::Migration[5.2]
  def change
    change_column :at_user_emoney_transactions, :used_date, :datetime
  end
end
