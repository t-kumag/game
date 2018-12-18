class AddIndexToAtCardAccount < ActiveRecord::Migration[5.2]
  def change
    add_index :at_user_card_accounts, [:at_user_id, :fnc_cd], :unique => true, :name => 'at_user_card_accounts_at_user_id_fnc_cd'
  end
end
