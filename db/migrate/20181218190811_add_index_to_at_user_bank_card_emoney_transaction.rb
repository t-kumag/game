class AddIndexToAtUserBankCardEmoneyTransaction < ActiveRecord::Migration[5.2]
  def change
    add_index :at_user_bank_transactions, [:at_user_bank_account_id, :seq], :unique => true, :name => 'at_user_bank_transactions_at_user_bank_account_id_seq'
    add_index :at_user_card_transactions, [:at_user_card_account_id, :seq], :unique => true, :name => 'at_user_card_transactions_at_user_card_account_id_seq'
    add_index :at_user_emoney_transactions, [:at_user_emoney_service_account_id, :seq], :unique => true, :name => 'at_user_emoney_transactions_at_user_emoney_account_id_seq'
  end
end
