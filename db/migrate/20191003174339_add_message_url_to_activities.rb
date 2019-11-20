class AddMessageUrlToActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :url, :string, after: :activity_type
    add_column :activities, :message, :string, after: :url
  end
end
