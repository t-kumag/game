class AddColumnToUserProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :user_profiles, :push, :boolean
  end
end
