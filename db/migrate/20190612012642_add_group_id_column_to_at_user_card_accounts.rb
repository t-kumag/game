class AddGroupIdColumnToAtUserCardAccounts < ActiveRecord::Migration[5.2]
  def change
    add_reference :at_user_card_accounts, :group
  end
end
