class ChangeColumnToAtUserCardAccounts20190626 < ActiveRecord::Migration[5.2]
  def up
    change_column :at_user_card_accounts, :share, false, null: false, default: 0
  end

  def down
    change_column :at_user_card_accounts, :share
  end
end
