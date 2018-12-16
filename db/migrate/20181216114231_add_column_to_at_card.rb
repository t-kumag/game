class AddColumnToAtCard < ActiveRecord::Migration[5.2]
  def change
    add_column :at_cards, :fnc_cd, :string
    add_column :at_cards, :fnc_nm, :string
  end
end
