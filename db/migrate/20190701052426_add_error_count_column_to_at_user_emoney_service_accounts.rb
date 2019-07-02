class AddErrorCountColumnToAtUserEmoneyServiceAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :at_user_emoney_service_accounts, :error_count, :tinyint
  end
end
