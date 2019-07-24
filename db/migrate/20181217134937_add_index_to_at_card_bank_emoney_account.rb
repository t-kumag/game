class AddIndexToAtCardBankEmoneyAccount < ActiveRecord::Migration[5.2]
  def change
    add_index :at_user_bank_accounts, [:at_user_id, :fnc_id], :unique => true, :name => 'at_user_bank_accounts_at_user_id_fnc_id'
    add_index :at_user_card_accounts, [:at_user_id, :fnc_id], :unique => true, :name => 'at_user_card_accounts_at_user_id_fnc_id'
    add_index :at_user_emoney_service_accounts, [:at_user_id, :fnc_id], :unique => true, :name => 'at_user_emoney_service_accounts_at_user_id_fnc_id'
  end
end
