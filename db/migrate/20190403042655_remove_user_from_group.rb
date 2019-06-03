class RemoveUserFromGroup < ActiveRecord::Migration[5.2]
  def change
    remove_reference :groups, :user, foreign_key: true
  end
end
