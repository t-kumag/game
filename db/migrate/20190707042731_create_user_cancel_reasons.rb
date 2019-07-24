class CreateUserCancelReasons < ActiveRecord::Migration[5.2]
  def change
    create_table :user_cancel_reasons do |t|
      t.references :user, foreign_key: true
      t.text :cancel_reason

      t.timestamps
    end
  end
end
