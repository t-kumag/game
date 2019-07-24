class ChangeColumnToUserProfiles20190626 < ActiveRecord::Migration[5.2]
  def up
    change_column :user_profiles, :has_child, false, null: false, default: 0
    change_column :user_profiles, :push,      false, null: false, default: 0
  end

  def down
    change_column :user_profiles, :has_child
    change_column :user_profiles, :push
  end
end
