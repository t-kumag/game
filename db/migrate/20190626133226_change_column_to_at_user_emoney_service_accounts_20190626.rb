class ChangeColumnToAtUserEmoneyServiceAccounts20190626 < ActiveRecord::Migration[5.2]
  def up
    change_column :at_user_emoney_service_accounts, :balance, :bigint, null: false, default: 0
    change_column :at_user_emoney_service_accounts, :share,   false,   null: false, default: 0
  end

  def down
    change_column :at_user_emoney_service_accounts, :balance
    change_column :at_user_emoney_service_accounts, :share
  end
end
