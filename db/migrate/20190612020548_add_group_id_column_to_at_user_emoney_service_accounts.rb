class AddGroupIdColumnToAtUserEmoneyServiceAccounts < ActiveRecord::Migration[5.2]
  def change
    add_reference :at_user_emoney_service_accounts, :group
  end
end
