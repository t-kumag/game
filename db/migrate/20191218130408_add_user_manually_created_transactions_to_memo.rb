class AddUserManuallyCreatedTransactionsToMemo < ActiveRecord::Migration[5.2]

  def change
    add_column :user_manually_created_transactions, :memo, :text, default: nil, after: :used_location
  end
end
