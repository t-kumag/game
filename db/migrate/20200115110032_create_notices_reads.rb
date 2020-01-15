class CreateNoticesReads < ActiveRecord::Migration[5.2]
  def change
    create_table :notices_reads do |t|
      t.references :notice, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :read

      t.timestamps
    end
  end
end
