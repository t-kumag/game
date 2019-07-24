class CreateUserBudgetQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_budget_questions do |t|
      t.references :user, foreign_key: true
      t.references :budget_question, foreign_key: true
      t.integer :step, null: false
      t.timestamps null: false
    end
  end
end
