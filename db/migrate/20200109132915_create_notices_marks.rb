class CreateNoticesMarks < ActiveRecord::Migration[5.2]
  def change
    create_table :notices_marks do |t|
      t.references :notice, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :mark
      t.timestamps

      t.timestamps
    end
  end
end
