class CreateParticipateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :participate_groups do |t|
      t.references :group, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
