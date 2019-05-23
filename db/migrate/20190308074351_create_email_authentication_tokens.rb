class CreateEmailAuthenticationTokens < ActiveRecord::Migration[5.2]
  def change
    create_table :email_authentication_tokens do |t|
      t.string :token, null: false
      t.date :expires_at, null: false
      t.references :users, null: false, foreign_key: true
      t.timestamps
    end
  end
end
