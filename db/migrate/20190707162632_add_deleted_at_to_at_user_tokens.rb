class AddDeletedAtToAtUserTokens < ActiveRecord::Migration[5.2]
  def change
    add_column :at_user_tokens, :deleted_at, :datetime
    add_index :at_user_tokens, :deleted_at
  end
end
