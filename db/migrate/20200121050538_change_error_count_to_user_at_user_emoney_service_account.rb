class ChangeErrorCountToUserAtUserEmoneyServiceAccount < ActiveRecord::Migration[5.2]
  def up
    change_column :at_user_emoney_service_accounts, :error_count, :integer
  end
end
