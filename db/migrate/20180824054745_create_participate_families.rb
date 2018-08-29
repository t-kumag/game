class CreateParticipateFamilies < ActiveRecord::Migration[5.2]
  def change
    create_table :participate_families do |t|
      t.references :family, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
