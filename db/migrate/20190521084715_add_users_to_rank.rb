class AddUsersToRank < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :rank, :integer, default: 0
  end
end
