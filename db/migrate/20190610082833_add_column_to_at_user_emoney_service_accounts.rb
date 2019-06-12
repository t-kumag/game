class AddColumnToAtUserEmoneyServiceAccounts < ActiveRecord::Migration[5.2]
  def change
    add_column :at_user_emoney_service_accounts, :deleted_at, :datetime
    add_index :at_user_emoney_service_accounts, :deleted_at
  end
end
