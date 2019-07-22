class CreateUserCancelQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_cancel_questions do |t|
      t.text :cancel_reason

      t.timestamps
    end
  end
end
