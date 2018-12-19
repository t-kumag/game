class AddColumnToAtCardBankEmoney < ActiveRecord::Migration[5.2]

  def change
    add_column :at_banks, :fnc_cd, :string
    add_column :at_banks, :fnc_nm, :string
    add_column :at_cards, :fnc_cd, :string
    add_column :at_cards, :fnc_nm, :string
    add_column :at_emoney_services, :fnc_cd, :string
    add_column :at_emoney_services, :fnc_nm, :string
  
  end
end
