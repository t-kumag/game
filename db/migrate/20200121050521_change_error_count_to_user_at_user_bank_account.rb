class ChangeErrorCountToUserAtUserBankAccount < ActiveRecord::Migration[5.2]
  def up
    change_column :at_user_bank_accounts, :error_count, :integer
  end
end
