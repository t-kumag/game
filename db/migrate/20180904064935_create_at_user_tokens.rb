class CreateAtUserTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :at_user_tokens do |t|
      t.references :at_user, foreign_key: true
      t.string :token
      t.timestamp :expires_at

      t.timestamps
    end
  end
end
