class AddErrorCountColumnToAtUserCardAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :at_user_card_accounts, :error_count, :tinyint
  end
end
