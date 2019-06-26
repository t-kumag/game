class CreateActivitiesSyncDates < ActiveRecord::Migration[5.2]
  def change
    create_table :activities_sync_dates do |t|
      t.integer :user_id , null:false
      t.date :date, null: false
      t.timestamps
    end
  end
end
