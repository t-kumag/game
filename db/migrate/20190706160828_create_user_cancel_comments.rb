class CreateUserCancelComments < ActiveRecord::Migration[5.2]
  def change
    create_table :user_cancel_comments do |t|
      t.references :user, foreign_key: true
      t.text :cancel_comment

      t.timestamps
    end
  end
end
