class AddWalletIdToGoalLogs < ActiveRecord::Migration[5.2]
  def change
    add_reference :goal_logs, :wallet, after: :at_user_bank_account_id, foreign_key: true
  end
end
