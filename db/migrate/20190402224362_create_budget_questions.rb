class CreateBudgetQuestions < ActiveRecord::Migration[5.2]
  def change
    create_table :budget_questions do |t|
      t.integer :question_type, null: false
      t.timestamps null: false
    end
  end
end
