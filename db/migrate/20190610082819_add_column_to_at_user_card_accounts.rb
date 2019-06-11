class AddColumnToAtUserCardAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :at_user_card_accounts, :deleted_at, :datetime
    add_index :at_user_card_accounts, :deleted_at
  end
end
