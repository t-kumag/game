class ChangeUserGroupReference < ActiveRecord::Migration[5.2]
  def change
    remove_reference :user_groups, :goal, foreign_key: true
    add_reference :user_groups, :group, foreign_key: true, index: true
  end
end
