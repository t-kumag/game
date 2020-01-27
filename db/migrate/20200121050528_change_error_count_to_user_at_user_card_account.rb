class ChangeErrorCountToUserAtUserCardAccount < ActiveRecord::Migration[5.2]
  def up
    change_column :at_user_card_accounts, :error_count, :integer
  end
end
