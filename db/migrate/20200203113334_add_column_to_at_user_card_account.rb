class AddColumnToAtUserCardAccount < ActiveRecord::Migration[5.2]
  def change
    add_column :at_user_card_accounts, :name, :string
  end
end
