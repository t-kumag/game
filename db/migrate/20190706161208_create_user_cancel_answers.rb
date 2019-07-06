class CreateUserCancelAnswers < ActiveRecord::Migration[5.2]
  def change
    create_table :user_cancel_answers do |t|
      t.references :user, foreign_key: true
      t.references :user_cancel_question, foreign_key: true

      t.timestamps
    end
  end
end
