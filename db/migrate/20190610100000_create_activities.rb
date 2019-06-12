class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities do |t|
      t.integer :user_id , null:false
      t.integer :partner_user_id
      t.integer :count , null:false
      t.string :activity_type, null: false
      t.date :date, null: false
      t.timestamps
    end
  end
end
