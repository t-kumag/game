class AddErrorDateColumnToAtUserCardAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :at_user_card_accounts, :error_date, :datetime
  end
end
