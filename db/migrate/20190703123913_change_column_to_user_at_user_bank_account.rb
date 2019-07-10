class ChangeColumnToUserAtUserBankAccount < ActiveRecord::Migration[5.2]
  def up
    change_column_default(:at_user_bank_accounts, :error_count, 0)
  end

  def down
    change_column_default(:at_user_bank_accounts, :error_count, nil)
  end
end
