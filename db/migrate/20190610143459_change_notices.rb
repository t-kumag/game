class ChangeNotices < ActiveRecord::Migration[5.2]
  def change
    remove_column :notices, :description, :string
  end
end
