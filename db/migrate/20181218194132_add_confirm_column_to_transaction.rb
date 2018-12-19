class AddConfirmColumnToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :at_user_card_transactions, :confirm_type, :string
    add_column :at_user_bank_transactions, :confirm_type, :string
    add_column :at_user_emoney_transactions, :confirm_type, :string
  end
end
