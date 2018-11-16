class CreateAtCards < ActiveRecord::Migration[5.2]
  def change
    create_table :at_cards do |t|

      t.timestamps
    end
  end
end
