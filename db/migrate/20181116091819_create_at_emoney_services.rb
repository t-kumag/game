class CreateAtEmoneyServices < ActiveRecord::Migration[5.2]
  def change
    create_table :at_emoney_services do |t|

      t.timestamps
    end
  end
end
