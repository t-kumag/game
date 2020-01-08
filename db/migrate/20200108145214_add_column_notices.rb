class AddColumnNotices < ActiveRecord::Migration[5.2]
  def change
    add_column :notices, :marked, :boolean, default: false, null: false, after: :url
  end
end
