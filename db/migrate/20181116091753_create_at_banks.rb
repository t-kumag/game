class CreateAtBanks < ActiveRecord::Migration[5.2]
  def change
    create_table :at_banks do |t|

      t.timestamps
    end
  end
end
